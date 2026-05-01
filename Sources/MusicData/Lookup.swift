//
//  Lookup.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation

/// A public facade for querying archive data by stable identifiers.
///
/// `Lookup` exposes read-only, precomputed relationships and rankings for artists, venues,
/// and shows. It wraps internal processing performed by `Bracket` and provides convenient
/// APIs for `Vault` to fetch related items, sort keys, and date-based groupings.
///
/// - Generic Parameter Identifier: An `ArchiveIdentifier` that defines the stable ID types used
///   throughout the lookup APIs.
public struct Lookup<Identifier: ArchiveIdentifier>: Codable, Sendable {
  /// Convenience alias for the stable identifier type used for artists, venues, and shows.
  public typealias ID = Identifier.ID
  /// Convenience alias for the stable identifier type used for year-like (annum) groupings.
  public typealias AnnumID = Identifier.AnnumID

  private let bracket: Bracket<Identifier>
  private let relationMap: [ID: Set<ID>]  // Artist/Venue ID : Set<Artist/Venue ID>
  let annumMap: [AnnumID: Annum]

  private let showIDOrderIndex: [ID: Int]

  /// Creates a `Lookup` by indexing the provided `Music` archive and preparing derived maps.
  ///
  /// Construction performs work concurrently to minimize initialization time.
  ///
  /// - Parameters:
  ///   - music: The source archive from which to derive lookups.
  ///   - identifier: An `ArchiveIdentifier` used to generate stable IDs for all lookups.
  /// - Throws: Any error encountered while reading the archive or computing derived structures.
  public init(music: Music, identifier: Identifier) async throws {
    var signpost = Signpost(category: "lookup", name: "process")
    signpost.start()

    async let bracket = await Bracket(music: music, identifier: identifier)
    async let relations = music.relationMap(identifier: identifier)

    self.bracket = try await bracket
    self.relationMap = try await relations
    self.annumMap = try await bracket.annumShows.keys.reduce(into: [:]) {
      $0[$1] = identifier.annum(for: $1)
    }

    self.showIDOrderIndex = Dictionary(
      uniqueKeysWithValues: try await bracket.sortedShowIDs().enumerated().map { ($1, $0) })
  }

  func compareIDs(lhs: ID, rhs: ID) throws -> Bool {
    try bracket.compareIDs(lhs: lhs, rhs: rhs)
  }

  func sort(showIDs: any Collection<ID>) throws -> [ID] {
    try showIDs.sorted { lhs, rhs in
      guard let lhsIndex = showIDOrderIndex[lhs] else {
        throw TokenSearchError.invalidCompareTokenID(lhs.description)
      }

      guard let rhsIndex = showIDOrderIndex[rhs] else {
        throw TokenSearchError.invalidCompareTokenID(rhs.description)
      }

      return lhsIndex < rhsIndex
    }
  }

  var showMap: [ID: Show] {
    bracket.showMap
  }

  var artistMap: [ID: Artist] {
    bracket.artistMap
  }

  var venueMap: [ID: Venue] {
    bracket.venueMap
  }

  /// Groups shows by decade, then by annum (e.g., year), returning the count of Shows for each.
  public func decadesMap(showIDs: Set<ID>) -> [Decade: [Annum: Int]] {
    let matchingAnnumShows = annumShows.reduce(into: [AnnumID: Set<ID>]()) {
      let (key, value) = $1
      let matchedShowIDs = value.intersection(showIDs)
      if !matchedShowIDs.isEmpty {
        $0[key] = matchedShowIDs
      }
    }
    return decadesMap(for: matchingAnnumShows)
  }

  public func decadesMap(for annumShows: [AnnumID: Set<ID>]) -> [Decade: [Annum: Int]] {
    annumShows.reduce(into: [Decade: [Annum: Int]]()) {
      guard let annum = annumMap[$1.key] else { return }
      let decade = annum.decade
      var arr = $0[decade] ?? [:]
      arr[annum] = $1.value.count
      $0[decade] = arr
    }
  }

  public var decadesMap: [Decade: [Annum: Int]] {
    decadesMap(for: annumShows)
  }

  public var annumShows: [AnnumID: Set<ID>] {
    bracket.annumShows
  }

  /// Maps a day-of-leap-year index (1...366) to the set of show IDs that occurred on that day.
  public var concertDayMap: [Int: Set<ID>] {
    bracket.concertDayMap
  }

  /// Returns all show IDs associated with the specified artist.
  ///
  /// - Parameter artistID: The stable artist identifier.
  /// - Returns: A set of show IDs the artist performed.
  public func shows(artistID: ID) -> Set<ID> {
    bracket.artistShows[artistID] ?? []
  }

  /// Returns all show IDs associated with the specified venue.
  ///
  /// - Parameter venueID: The stable venue identifier.
  /// - Returns: A set of show IDs hosted at the venue.
  public func shows(venueID: ID) -> Set<ID> {
    bracket.venueShows[venueID] ?? []
  }

  /// Returns all artist IDs that have performed at the specified venue.
  ///
  /// - Parameter venueID: The stable venue identifier.
  /// - Returns: A set of artist IDs.
  public func artists(venueID: ID) -> Set<ID> {
    bracket.venueArtists[venueID] ?? []
  }

  /// Returns all artist IDs that performed in the specified show.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: An array of artist IDs that appeared in the show, headliner to opener.
  public func artists(showID: ID) -> [ID] {
    bracket.showArtists[showID] ?? []
  }

  /// Returns the venue ID associated with the specified show.
  ///
  /// Shows have a single venue; this returns a set for consistency with other APIs.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: The venue ID for the show, if available; otherwise nil.
  public func venues(showID: ID) -> ID? {
    bracket.showVenue[showID]
  }

  /// Looks up the venue for a given show.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: The `Venue` if found, otherwise `nil`.
  public func venueForShow(showID: ID) -> Venue? {
    guard let venueID = venues(showID: showID) else { return nil }
    return venueMap[venueID]
  }

  /// Looks up all artists for a given show.
  ///
  /// - Parameter showID: The stable show identifier.
  /// - Returns: An array of `Artist` values, in the order they are stored for the show.
  public func artistsForShow(showID: ID) -> [Artist] {
    artists(showID: showID).compactMap { artistMap[$0] }
  }

  func rankDigest(annum: AnnumID) -> RankDigest {
    bracket.annumRankDigestMap[annum] ?? .empty
  }

  func rankDigest(artist: ID) -> RankDigest {
    bracket.artistRankDigestMap[artist] ?? .empty
  }

  func rankDigest(venue: ID) -> RankDigest {
    bracket.venueRankDigestMap[venue] ?? .empty
  }

  /// Returns venues related to the given venue.
  ///
  /// Relatedness is domain-specific (e.g., shared characteristics or associations) and is
  /// expressed as lightweight `ArchiveItem` values suitable for UI display.
  ///
  /// - Parameter venueID: The stable venue identifier.
  /// - Returns: A collection of related items.
  public func related(venueID: ID) -> any Collection<ArchiveItem> {
    relationMap[venueID]?.compactMap { venueMap[$0] }.map {
      ArchiveItem(id: $0.archivePath, name: $0.name)
    } ?? []
  }

  /// Returns artists related to the given artist.
  ///
  /// Relatedness is domain-specific and is expressed as lightweight `Related` values suitable
  /// for UI display.
  ///
  /// - Parameter artistID: The stable artist identifier.
  /// - Returns: A collection of related items.
  public func related(artistID: ID) -> any Collection<ArchiveItem> {
    relationMap[artistID]?.compactMap { artistMap[$0] }.map {
      ArchiveItem(id: $0.archivePath, name: $0.name)
    } ?? []
  }

  /// Returns the most recent concert identifiers.
  ///
  /// The order reflects chronological ordering of shows with fully known dates.
  ///
  /// - Parameter count: The number of most-recent shows to return.
  /// - Returns: An array of show IDs ordered from oldest to newest within the requested window.
  public func recentConcerts(_ count: Int) -> [ID] {
    bracket.showOrder.suffix(count)
  }
}
