//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault<Identifier: ArchiveIdentifier>: Sendable
where Identifier.ID == ArchivePath {
  public typealias ID = Identifier.ID

  public let rootURL: URL

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let lookup: Lookup<Identifier>

  init(lookup: Lookup<Identifier>, rootURL: URL) {
    self.lookup = lookup
    self.rootURL = rootURL

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: rootURL) else { return }
      $0[$1] = url
    }
  }

  public init(url: URL, identifier: Identifier, previousModified: Date) async throws {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    guard let rootURL = url.rootURL else { throw VaultError.noRootURL(url.absoluteString) }

    async let asyncLookup = await Lookup(
      url: url,
      identifier: identifier,
      previousModified: previousModified)
    self.init(lookup: try await asyncLookup, rootURL: rootURL)
  }

  public var decadesMap: [Decade: [Annum: Int]] {
    lookup.decadesMap
  }

  public func decadesMap(showIDs: Set<ID>) -> [Decade: [Annum: Int]] {
    lookup.decadesMap(showIDs: showIDs)
  }

  /// The URL for this category.
  public func url(for category: ArchiveCategory) -> URL? {
    categoryURLLookup[category]
  }

  public func url(for path: ArchivePath) -> URL? {
    path.url(using: rootURL)
  }

  fileprivate func concertIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int)
    -> any Collection<ID>
  {
    lookup.concertDayMap[dayOfLeapYear] ?? lookup.recentConcerts(recentCount)
  }

  /// Returns artist IDs for shows on a specific day or, if none, the most recent shows.
  ///
  /// If there are shows on the given day-of-leap-year index, the returned collection contains
  /// the artists who performed those shows. Otherwise, this falls back to the artists from the
  /// most recent `recentCount` shows.
  ///
  /// - Parameters:
  ///   - dayOfLeapYear: The day-of-leap-year index (1...366) to query.
  ///   - recentCount: The number of recent shows to consider when there are no shows on that day.
  /// - Returns: A collection of artist IDs, capped to the most recent `recentCount` entries.
  public func artistIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int) -> any Collection<ID>
  {
    concertIDs(on: dayOfLeapYear, orRecentCount: recentCount).flatMap { lookup.artists(showID: $0) }
      .suffix(recentCount)
  }

  /// Returns venue IDs for shows on a specific day or, if none, the most recent shows.
  ///
  /// If there are shows on the given day-of-leap-year index, the returned collection contains
  /// the venues that hosted those shows. Otherwise, this falls back to the venues from the
  /// most recent `recentCount` shows.
  ///
  /// - Parameters:
  ///   - dayOfLeapYear: The day-of-leap-year index (1...366) to query.
  ///   - recentCount: The number of recent shows to consider when there are no shows on that day.
  /// - Returns: A collection of venue IDs, capped to the most recent `recentCount` entries.
  public func venueIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int) -> any Collection<ID>
  {
    concertIDs(on: dayOfLeapYear, orRecentCount: recentCount).compactMap {
      lookup.venues(showID: $0)
    }
    .suffix(recentCount)
  }

  public func concerts(on dayOfLeapYear: Int) throws -> [ShowDigest] {
    try sort(showIDs: lookup.concertDayMap[dayOfLeapYear] ?? []).compactMap {
      lookup.showDigest(showId: $0)
    }
  }

  public func sort(showIDs: any Collection<ID>) throws -> [ID] {
    try lookup.sort(showIDs: showIDs)
  }

  public func compareIDs(lhs: ID, rhs: ID) throws -> Bool {
    try lookup.compareIDs(lhs: lhs, rhs: rhs)
  }

  public func artistIDs(filteredBy searchString: String) -> any Sequence<ID> {
    guard !searchString.isEmpty else { return [] }

    return lookup.artistMap.compactMap {
      guard $0.value.filter(by: searchString) else { return nil }
      return $0.key
    }
  }

  public func artists(filteredBy searchString: String) throws -> [ArchiveItem] {
    guard !searchString.isEmpty else { return [] }

    let matchingPairs: [(ID, Artist)] = artistIDs().compactMap {
      guard $0.1.filter(by: searchString) else { return nil }
      return $0
    }
    return try matchingPairs.sorted(by: {
      try lookup.compareIDs(lhs: $0.0, rhs: $1.0)
    }).map { ArchiveItem(id: $0.0, name: $0.1.name) }
  }

  public func venueIDs(filteredBy searchString: String) -> any Sequence<ID> {
    guard !searchString.isEmpty else { return [] }

    return lookup.venueMap.compactMap {
      guard $0.value.filter(by: searchString) else { return nil }
      return $0.key
    }
  }

  public func venues(filteredBy searchString: String) throws -> [ArchiveItem] {
    guard !searchString.isEmpty else { return [] }

    let matchingPairs: [(ID, Venue)] = venueIDs().compactMap {
      guard $0.1.filter(by: searchString) else { return nil }
      return $0
    }
    return try matchingPairs.sorted(by: {
      try lookup.compareIDs(lhs: $0.0, rhs: $1.0)
    }).map { ArchiveItem(id: $0.0, name: $0.1.name) }
  }

  public func digest(annum: ID) -> AnnumDigest<ID>? {
    lookup.annumDigest(id: annum)
  }

  public func digest(artist: ID) -> ArtistDigest<ID>? {
    lookup.artistDigest(id: artist)
  }

  public func digest(venue: ID) -> VenueDigest<ID>? {
    lookup.venueDigest(id: venue)
  }

  public func digest(show: ID) -> ShowDigest? {
    lookup.showDigest(showId: show)
  }

  public func venueIDs() -> [(ID, Venue)] {
    lookup.venueMap.map { ($0, $1) }
  }

  public func artistIDs() -> [(ID, Artist)] {
    lookup.artistMap.map { ($0, $1) }
  }

  public func shows() -> [Show] {
    Array(lookup.showMap.values)
  }

  public func showIDs() -> Set<ID> {
    Set(lookup.showMap.keys)
  }

  public func artists(venueID: ID) -> Set<ID> {
    lookup.artists(venueID: venueID)
  }

  public func shows(artistID: ID) -> Set<ID> {
    lookup.shows(artistID: artistID)
  }

  public func shows(venueID: ID) -> Set<ID> {
    lookup.shows(venueID: venueID)
  }

  public func rankedArtist(id: ID) -> RankedArchiveItem? {
    lookup.artistMap[id]?.rankedArchiveItem(id: id, lookup.rankDigest(artist: id))
  }

  public func rankedVenue(id: ID) -> RankedArchiveItem? {
    lookup.venueMap[id]?.rankedArchiveItem(id: id, lookup.rankDigest(venue: id))
  }

  public var statisticsData:
    (showsCount: Int, venueCount: Int, artistCount: Int, dates: [Date], states: [String: Int])
  {
    (
      lookup.showMap.count,
      lookup.venueMap.count,
      lookup.artistMap.count,
      lookup.showMap.values.map { $0.date }.knownDates,
      lookup.venueMap.flatMap { (id, venue) in
        Array(repeating: venue.location, count: self.shows(venueID: id).count)
      }.stateCounts
    )
  }

  /// The statistics of just these venues and their shows.
  public func statisticsData(venueIDs: any Collection<ID>)
    -> (showsCount: Int, venueCount: Int, artistCount: Int, dates: [Date], states: [String: Int])
  {
    let venues = venueIDs.compactMap { id in lookup.venueMap[id].map { (id, $0) } }
    let showIDs = Set(venues.flatMap { shows(venueID: $0.0) })
    return (
      showIDs.count,
      venues.count,
      Set(venues.flatMap { artists(venueID: $0.0) }).count,
      showIDs.compactMap { lookup.showMap[$0]?.date }.knownDates,
      venues.flatMap { (id, venue) in
        Array(repeating: venue.location, count: self.shows(venueID: id).count)
      }.stateCounts
    )
  }

  public var timestamp: Date {
    lookup.timestamp
  }
}
