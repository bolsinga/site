//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault: Sendable {
  public let rootURL: URL

  /// The artists in library order, for paging from one to the next.
  public let orderedArtistIDs: [ArchivePath]
  /// The venues in library order, for paging from one to the next.
  public let orderedVenueIDs: [ArchivePath]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let lookup: Lookup

  init(lookup: Lookup, rootURL: URL) {
    self.lookup = lookup
    self.rootURL = rootURL
    self.orderedArtistIDs = lookup.libraryOrder(of: lookup.artistMap.keys)
    self.orderedVenueIDs = lookup.libraryOrder(of: lookup.venueMap.keys)

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: rootURL) else { return }
      $0[$1] = url
    }
  }

  public init(url: URL, previousModified: Date) async throws {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    guard let rootURL = url.rootURL else { throw VaultError.noRootURL(url.absoluteString) }

    async let asyncLookup = await Lookup(url: url, previousModified: previousModified)
    self.init(lookup: try await asyncLookup, rootURL: rootURL)
  }

  public var decadesMap: [Decade: [Annum: Int]] {
    lookup.decadesMap
  }

  public func decadesMap(showIDs: Set<ArchivePath>) -> [Decade: [Annum: Int]] {
    lookup.decadesMap(showIDs: showIDs)
  }

  /// The URL for this category.
  public func url(for category: ArchiveCategory) -> URL? {
    categoryURLLookup[category]
  }

  public func url(for path: ArchivePath) -> URL? {
    path.url(using: rootURL)
  }

  /// The shows on a day-of-leap-year or, if none, the most recent `recentCount` shows.
  public func concertIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int)
    -> any Collection<ArchivePath>
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
  public func artistIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int) -> any Collection<
    ArchivePath
  > {
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
  public func venueIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int) -> any Collection<
    ArchivePath
  > {
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

  public func sort(showIDs: any Collection<ArchivePath>) throws -> [ArchivePath] {
    try lookup.sort(showIDs: showIDs)
  }

  public func compareIDs(lhs: ArchivePath, rhs: ArchivePath) throws -> Bool {
    try lookup.compareIDs(lhs: lhs, rhs: rhs)
  }

  public func artistIDs(filteredBy searchString: String) -> any Sequence<ArchivePath> {
    guard !searchString.isEmpty else { return [] }

    return lookup.artistMap.compactMap {
      guard $0.value.filter(by: searchString) else { return nil }
      return $0.key
    }
  }

  public func artists(filteredBy searchString: String) throws -> [ArchiveItem] {
    guard !searchString.isEmpty else { return [] }

    let matchingPairs: [(ArchivePath, Artist)] = artistIDs().compactMap {
      guard $0.1.filter(by: searchString) else { return nil }
      return $0
    }
    return try matchingPairs.sorted(by: {
      try lookup.compareIDs(lhs: $0.0, rhs: $1.0)
    }).map { ArchiveItem(id: $0.0, name: $0.1.name) }
  }

  public func venueIDs(filteredBy searchString: String) -> any Sequence<ArchivePath> {
    guard !searchString.isEmpty else { return [] }

    return lookup.venueMap.compactMap {
      guard $0.value.filter(by: searchString) else { return nil }
      return $0.key
    }
  }

  public func venues(filteredBy searchString: String) throws -> [ArchiveItem] {
    guard !searchString.isEmpty else { return [] }

    let matchingPairs: [(ArchivePath, Venue)] = venueIDs().compactMap {
      guard $0.1.filter(by: searchString) else { return nil }
      return $0
    }
    return try matchingPairs.sorted(by: {
      try lookup.compareIDs(lhs: $0.0, rhs: $1.0)
    }).map { ArchiveItem(id: $0.0, name: $0.1.name) }
  }

  /// How a day of the leap year ranks among the days that have shows.
  public func dayRankDigest(on dayOfLeapYear: Int) -> RankDigest {
    lookup.dayRankDigest(on: dayOfLeapYear)
  }

  public func rankDistribution(_ kind: RankKind, _ metric: RankMetric) -> RankDistribution {
    lookup.rankDistribution(kind, metric)
  }

  public func firstSetCount(_ kind: RankKind) -> Int {
    lookup.firstSetCount(kind)
  }

  public func digest(annum: Annum) -> AnnumDigest? {
    lookup.annumDigest(annum: annum)
  }

  public func digest(artist: ArchivePath) -> ArtistDigest? {
    lookup.artistDigest(id: artist)
  }

  public func digest(venue: ArchivePath) -> VenueDigest? {
    lookup.venueDigest(id: venue)
  }

  public func digest(show: ArchivePath) -> ShowDigest? {
    lookup.showDigest(showId: show)
  }

  public func venueIDs() -> [(ArchivePath, Venue)] {
    lookup.venueMap.map { ($0, $1) }
  }

  public func artistIDs() -> [(ArchivePath, Artist)] {
    lookup.artistMap.map { ($0, $1) }
  }

  public func shows() -> [Show] {
    Array(lookup.showMap.values)
  }

  public func showIDs() -> Set<ArchivePath> {
    Set(lookup.showMap.keys)
  }

  public func artists(venueID: ArchivePath) -> Set<ArchivePath> {
    lookup.artists(venueID: venueID)
  }

  public func shows(artistID: ArchivePath) -> Set<ArchivePath> {
    lookup.shows(artistID: artistID)
  }

  public func shows(venueID: ArchivePath) -> Set<ArchivePath> {
    lookup.shows(venueID: venueID)
  }

  public func rankedArtist(id: ArchivePath) -> RankedArchiveItem? {
    lookup.artistMap[id]?.rankedArchiveItem(id: id, lookup.rankDigest(artist: id))
  }

  public func rankedVenue(id: ArchivePath) -> RankedArchiveItem? {
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
  public func statisticsData(venueIDs: any Collection<ArchivePath>)
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
