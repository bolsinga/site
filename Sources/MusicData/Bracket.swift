//
//  Bracket.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation
import OrderedCollections

extension Music {
  /// Builds a map from stable archive identifiers to a tokenized library sort string.
  ///
  /// This precomputes normalized sort tokens for both artists and venues so that
  /// higher-level views can sort quickly without repeatedly allocating tokenizers.
  ///
  /// - Parameters:
  ///   - identifier: An `ArchiveIdentifier` that converts model IDs into stable, comparable IDs.
  /// - Returns: A dictionary mapping `Identifier.ID` to a normalized sort token string.
  /// - Throws: Rethrows any errors encountered while resolving identifiers for artists or venues.
  fileprivate func librarySortTokenMap<Identifier: ArchiveIdentifier>(_ identifier: Identifier)
    throws -> [Identifier.ID: String]
  {
    let tokenizer = LibraryCompareTokenizer()
    return try artists.reduce(
      into: try venues.reduce(into: [:]) {
        $0[try identifier.venue($1.id)] = tokenizer.removeCommonInitialPunctuation(
          $1.librarySortString)
      }
    ) {
      $0[try identifier.artist($1.id)] = tokenizer.removeCommonInitialPunctuation(
        $1.librarySortString)
    }
  }
}

/// A precomputed snapshot of ranking and lookup data for fast querying and display.
///
/// `Bracket` consolidates several derived maps from the music archive, such as rank digests,
/// decade groupings, and show relationships. It is intended to be created off the main thread
/// and then shared read-only across views for efficient access.
///
/// - Generic Parameter Identifier: An `ArchiveIdentifier` that defines the stable ID types used
///   throughout the snapshot.
struct Bracket<Identifier: ArchiveIdentifier>: Codable, Sendable {
  /// Convenience alias for the stable identifier type used for artists and venues.
  typealias ID = Identifier.ID
  /// Convenience alias for the stable identifier type used for year-like (annum) groupings.
  typealias AnnumID = Identifier.AnnumID

  /// Maps any archive `ID` to a normalized token used for locale-aware, punctuation-tolerant sorting.
  let librarySortTokenMap: [ID: String]
  /// Aggregated ranking metrics for each artist, used to sort or filter artist lists.
  let artistRankDigestMap: [ID: RankDigest]
  /// Aggregated ranking metrics for each venue, used to sort or filter venue lists.
  let venueRankDigestMap: [ID: RankDigest]
  /// Aggregated ranking metrics for each annum (e.g., year), keyed by `AnnumID`.
  let annumRankDigestMap: [AnnumID: RankDigest]
  /// Groups annums by decade and lists the set of show `ID`s that belong to each annum.
  let decadesMap: [Decade: [AnnumID: Set<ID>]]
  /// Maps a day-of-leap-year index (1...366) to the set of show `ID`s that occurred on that day.
  let concertDayMap: [Int: Set<ID>]
  /// For each artist `ID`, the set of show `ID`s they performed.
  let artistShows: [ID: Set<ID>]
  /// For each venue `ID`, the set of show `ID`s hosted there.
  let venueShows: [ID: Set<ID>]
  /// For each venue `ID`, the set of artist `ID`s that have performed at that venue.
  let venueArtists: [ID: Set<ID>]
  /// Ordered sequence of show IDs with fully known dates, used to resolve recency.
  let showOrder: OrderedSet<ID>
  /// For each show `ID`, the array of artist `ID`s that performed at that show, in order from headliner to opener.
  let showArtists: [ID: [ID]]
  // Venue ID for Show IDs.
  let showVenue: [ID: ID]

  /// Creates a new `Bracket` by deriving ranking and lookup maps from the provided `Music` archive.
  ///
  /// Work is performed concurrently where possible to minimize construction time. Prefer creating
  /// this snapshot off the main thread and then passing it into views.
  ///
  /// - Parameters:
  ///   - music: The source archive from which to derive ranks and relationships.
  ///   - identifier: An `ArchiveIdentifier` used to generate stable IDs for all derived maps.
  /// - Throws: Any error encountered while reading the archive or computing derived structures.
  init(music: Music, identifier: Identifier) async throws {
    var signpost = Signpost(category: "bracket", name: "process")
    signpost.start()

    async let librarySortTokenMap = music.librarySortTokenMap(identifier)

    async let tracker = try Tracker(shows: music.shows, identifier: identifier)

    self.artistRankDigestMap = try await tracker.artistRankDigests()
    self.venueRankDigestMap = try await tracker.venueRankDigests()
    self.annumRankDigestMap = try await tracker.annumRankDigests()
    self.decadesMap = try await tracker.decadesMap(decade: { identifier.decade($0) })
    self.concertDayMap = try await tracker.dayOfLeapYearShows
    self.artistShows = try await tracker.artistShows
    self.venueShows = try await tracker.venueShows
    self.venueArtists = try await tracker.venueArtists
    self.showOrder = try await tracker.showOrder
    self.showArtists = try await tracker.showArtists.mapValues { $0.reversed() }
    self.showVenue = try await tracker.showVenue

    self.librarySortTokenMap = try await librarySortTokenMap
  }
}
