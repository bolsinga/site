//
//  Bracket.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Algorithms
import Foundation
import OrderedCollections
import os

extension Logger {
  fileprivate static let libraryComparator = Logger(category: "libraryComparator")
}

extension Collection where Element == Artist {
  fileprivate func lookups<Identifier: ArchiveIdentifier>(
    _ identifier: Identifier, tokenizer: LibraryCompareTokenizer
  ) throws -> ([Identifier.ID: String], [Identifier.ID: Element]) {
    var sortTokenMap = [Identifier.ID: String]()
    var lookup = [Identifier.ID: Element]()

    try forEach {
      let id = try identifier.artist($0.id)
      sortTokenMap[id] = tokenizer.removeCommonInitialPunctuation($0.librarySortString)
      lookup[id] = $0
    }

    return (sortTokenMap, lookup)
  }
}

extension Collection where Element == Venue {
  fileprivate func lookups<Identifier: ArchiveIdentifier>(
    _ identifier: Identifier, tokenizer: LibraryCompareTokenizer
  ) throws -> ([Identifier.ID: String], [Identifier.ID: Element]) {
    var sortTokenMap = [Identifier.ID: String]()
    var lookup = [Identifier.ID: Element]()

    try forEach {
      let id = try identifier.venue($0.id)
      sortTokenMap[id] = tokenizer.removeCommonInitialPunctuation($0.librarySortString)
      lookup[id] = $0
    }

    return (sortTokenMap, lookup)
  }
}

extension Music {
  fileprivate func itemMaps<Identifier: ArchiveIdentifier>(_ identifier: Identifier) throws -> (
    artistTokens: [Identifier.ID: String], artistMap: [Identifier.ID: Artist],
    venueTokens: [Identifier.ID: String], venueMap: [Identifier.ID: Venue]
  ) {
    let tokenizer = LibraryCompareTokenizer()

    let (artistTokens, artistMap) = try self.artists.lookups(identifier, tokenizer: tokenizer)
    let (venueTokens, venueMap) = try self.venues.lookups(identifier, tokenizer: tokenizer)

    return (
      artistTokens: artistTokens, artistMap: artistMap, venueTokens: venueTokens, venueMap: venueMap
    )
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
  // Show for Show IDs.
  let showMap: [ID: Show]
  // Artist for Artist IDs.
  let artistMap: [ID: Artist]
  // Venue for Venue IDs.
  let venueMap: [ID: Venue]

  private let compareTokenMap: [ID: String]

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

    async let (artistSortTokens, artistMap, venueSortTokens, venueMap) = try music.itemMaps(
      identifier)

    async let tracker = try Tracker(shows: music.shows, identifier: identifier)

    self.artistRankDigestMap = try await tracker.artistRankDigests(
      sections: artistSortTokens.mapValues { $0.librarySection })
    self.venueRankDigestMap = try await tracker.venueRankDigests(
      sections: venueSortTokens.mapValues { $0.librarySection })
    self.annumRankDigestMap = try await tracker.annumRankDigests()
    self.decadesMap = try await tracker.decadesMap(decade: { identifier.decade($0) })
    self.concertDayMap = try await tracker.dayOfLeapYearShows
    self.artistShows = try await tracker.artistShows
    self.venueShows = try await tracker.venueShows
    self.venueArtists = try await tracker.venueArtists
    self.showOrder = try await tracker.showOrder
    self.showArtists = try await tracker.showArtists.mapValues { $0.reversed() }
    self.showVenue = try await tracker.showVenue
    self.showMap = try await tracker.showMap
    self.artistMap = try await artistMap
    self.venueMap = try await venueMap

    self.compareTokenMap = try await artistSortTokens.merging(try await venueSortTokens) {
      (_, new) in new
    }
  }

  func compareIDs(lhs: ID, rhs: ID) throws -> Bool {
    guard let lhToken = compareTokenMap[lhs] else {
      throw TokenSearchError.invalidCompareTokenID(lhs.description)
    }

    guard let rhToken = compareTokenMap[rhs] else {
      throw TokenSearchError.invalidCompareTokenID(rhs.description)
    }

    return lhToken.tokenCompare(other: rhToken)
  }

  func sortedShowIDs() throws -> [ID] {
    let showDate = {
      guard let show = showMap[$0] else {
        throw TokenSearchError.invalidCompareTokenID($0.description)
      }
      return show.date
    }

    let venueInfo = {
      guard let venueID = showVenue[$0] else {
        throw TokenSearchError.invalidCompareTokenID($0.description)
      }
      return venueID
    }

    let headlinerInfo = {
      guard let headlinerID = showArtists[$0]?.first else {
        throw TokenSearchError.invalidCompareTokenID($0.description)
      }
      return headlinerID
    }

    return try showMap.keys.sorted { (lhs: ID, rhs: ID) in
      let lhShowDate = try showDate(lhs)
      let rhShowDate = try showDate(rhs)
      if lhShowDate == rhShowDate {
        let lhVenue = try venueInfo(lhs)
        let rhVenue = try venueInfo(rhs)
        if lhVenue == rhVenue {
          let lhHeadliner = try headlinerInfo(lhs)
          let rhHeadliner = try headlinerInfo(rhs)
          if lhHeadliner == rhHeadliner {
            return lhs.description < rhs.description
          }
          return try compareIDs(lhs: lhHeadliner, rhs: rhHeadliner)
        }
        return try compareIDs(lhs: lhVenue, rhs: rhVenue)
      }
      return lhShowDate < rhShowDate
    }
  }
}
