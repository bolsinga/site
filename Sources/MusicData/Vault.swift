//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault<Identifier: ArchiveIdentifier>: Sendable {
  public typealias ID = Identifier.ID
  public typealias AnnumID = Identifier.AnnumID

  private let comparator: LibraryComparator<ID>
  public let sectioner: LibrarySectioner<ID>
  public let rootURL: URL

  public let artistDigestMap: [ID: ArtistDigest]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let lookup: Lookup<Identifier>

  public init(music: Music, url: URL, identifier: Identifier) async throws {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    async let asyncLookup = await Lookup(music: music, identifier: identifier)
    let lookup = try await asyncLookup
    self.lookup = lookup
    let comparator = LibraryComparator(tokenMap: lookup.librarySortTokenMap)

    async let artistDigestMap = lookup.artistDigestMap()

    self.comparator = comparator
    self.sectioner = await LibrarySectioner(librarySortTokenMap: lookup.librarySortTokenMap)
    self.rootURL = url

    self.artistDigestMap = try await artistDigestMap

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: url) else { return }
      $0[$1] = url
    }
  }

  var decadesMap: [Decade: [AnnumID: Set<ID>]] {
    lookup.decadesMap
  }

  /// The URL for this category.
  public func url(for category: ArchiveCategory) -> URL? {
    categoryURLLookup[category]
  }

  public func url(for item: PathRestorable) -> URL? {
    item.archivePath.url(using: rootURL)
  }

  func compare<Comparable: LibraryComparable>(lhs: Comparable, rhs: Comparable) -> Bool
  where Comparable.ID == ID {
    comparator.libraryCompare(lhs: lhs, rhs: rhs)
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
  func artistIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int) -> any Collection<ID> {
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
  func venueIDs(on dayOfLeapYear: Int, orRecentCount recentCount: Int) -> any Collection<ID> {
    concertIDs(on: dayOfLeapYear, orRecentCount: recentCount).flatMap { lookup.venues(showID: $0) }
      .suffix(recentCount)
  }

  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    lookup.concertDayMap[dayOfLeapYear]?.compactMap { lookup.concert(showId: $0) }.sorted(
      by: compare(lhs:rhs:)) ?? []
  }

  func compare(lhs: Concert, rhs: Concert) -> Bool {
    lookup.compareConcerts(lhs: lhs, rhs: rhs, comparator: comparator)
  }

  func compare<Comparable: LibraryComparable & PathRestorable>(lhs: Comparable, rhs: Comparable)
    -> Bool where Comparable.ID == String
  {
    lookup.libraryCompare(lhs: lhs, rhs: rhs, comparator: comparator)
  }

  func artists(filteredBy searchString: String) -> [Artist] {
    lookup.artistMap.values.names(filteredBy: searchString, additive: true).sorted(
      by: compare(lhs:rhs:))
  }

  func venues(filteredBy searchString: String) -> [Venue] {
    lookup.venueMap.values.names(filteredBy: searchString, additive: true).sorted(
      by: compare(lhs:rhs:))
  }

  func digest(annum: Annum) -> AnnumDigest? {
    try? lookup.annumDigest(annum: annum)
  }

  func digest(artist: ID) -> ArtistDigest? {
    lookup.artistDigest(id: artist)
  }

  func digest(venue: ID) -> VenueDigest? {
    lookup.venueDigest(id: venue)
  }

  func concert(show: ID) -> Concert? {
    lookup.concert(showId: show)
  }

  func venues() -> [Venue] {
    Array(lookup.venueMap.values)
  }

  func artists() -> [Artist] {
    Array(lookup.artistMap.values)
  }

  func shows() -> [Show] {
    Array(lookup.showMap.values)
  }

  func showIDs() -> Set<ID> {
    Set(lookup.showMap.keys)
  }

  func artists(venueID: ID) -> Set<ID> {
    lookup.artists(venueID: venueID)
  }

  func shows(artistID: ID) -> Set<ID> {
    lookup.shows(artistID: artistID)
  }

  func shows(venueID: ID) -> Set<ID> {
    lookup.shows(venueID: venueID)
  }

  func rankedArtist(id: ID) -> RankedArchiveItem? {
    lookup.artistMap[id]?.rankedArchiveItem(lookup.rankDigest(artist: id))
  }

  func rankedVenue(id: ID) -> RankedArchiveItem? {
    lookup.venueMap[id]?.rankedArchiveItem(lookup.rankDigest(venue: id))
  }

  var statisticsData:
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
}
