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

  private let identifier: Identifier
  private let comparator: LibraryComparator<ID>
  public let rootURL: URL

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let lookup: Lookup<Identifier>

  public init(music: Music, url: URL, identifier: Identifier) async throws {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    self.identifier = identifier

    async let asyncLookup = await Lookup(music: music, identifier: identifier)
    let lookup = try await asyncLookup
    self.lookup = lookup
    let comparator = LibraryComparator(tokenMap: lookup.librarySortTokenMap)

    self.comparator = comparator
    self.rootURL = url

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
    concertIDs(on: dayOfLeapYear, orRecentCount: recentCount).compactMap {
      lookup.venues(showID: $0)
    }
    .suffix(recentCount)
  }

  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    lookup.concertDayMap[dayOfLeapYear]?.compactMap { lookup.concert(showId: $0) }.sorted(
      by: compareConcerts(lhs:rhs:)) ?? []
  }

  /// Compares two concerts.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand concert to compare.
  ///   - rhs: The right-hand concert to compare.
  /// - Returns: `true` if `lhs` should be ordered before `rhs`.
  func compareConcerts(lhs: Concert, rhs: Concert) -> Bool {
    let lhShow = lhs.show
    let rhShow = rhs.show
    if lhShow.date == rhShow.date {
      let lhVenue = lhs.venue
      let rhVenue = rhs.venue
      if lhVenue == rhVenue {
        if let lhHeadliner = lhs.artists.first, let rhHeadliner = rhs.artists.first {
          if lhHeadliner == rhHeadliner {
            return lhs.id < rhs.id
          }
          return compare(lhs: lhHeadliner, rhs: rhHeadliner)
        }
      }
      return compare(lhs: lhVenue, rhs: rhVenue)
    }
    return lhShow.date < rhShow.date
  }

  /// Compares two library comparables (artists, venues, etc.).
  ///
  /// - Parameters:
  ///   - lhs: The left-hand item to compare.
  ///   - rhs: The right-hand item to compare.
  /// - Returns: `true` if `lhs` should be ordered before `rhs`.
  ///
  /// - Note: `Comparable.ID` must be `String`.
  func compare<Comparable: Identifiable & LibraryComparable & PathRestorable>(
    lhs: Comparable, rhs: Comparable
  )
    -> Bool where Comparable.ID == String
  {
    identifier.libraryCompare(lhs: lhs, rhs: rhs, comparator: comparator)
  }

  func artistIDs(filteredBy searchString: String) -> any Sequence<ID> {
    guard !searchString.isEmpty else { return [] }

    return lookup.artistMap.compactMap {
      guard $0.value.filter(by: searchString) else { return nil }
      return $0.key
    }
  }

  func artists(filteredBy searchString: String) -> [Artist] {
    guard !searchString.isEmpty else { return [] }

    let matchingPairs: [(ID, Artist)] = artistIDs().compactMap {
      guard $0.1.filter(by: searchString) else { return nil }
      return $0
    }
    return matchingPairs.sorted(by: {
      comparator.libraryCompare(lhs: $0.1, lhsID: $0.0, rhs: $1.1, rhsID: $1.0)
    }).map { $0.1 }
  }

  func venueIDs(filteredBy searchString: String) -> any Sequence<ID> {
    guard !searchString.isEmpty else { return [] }

    return lookup.venueMap.compactMap {
      guard $0.value.filter(by: searchString) else { return nil }
      return $0.key
    }
  }

  func venues(filteredBy searchString: String) -> [Venue] {
    guard !searchString.isEmpty else { return [] }

    let matchingPairs: [(ID, Venue)] = venueIDs().compactMap {
      guard $0.1.filter(by: searchString) else { return nil }
      return $0
    }
    return matchingPairs.sorted(by: {
      comparator.libraryCompare(lhs: $0.1, lhsID: $0.0, rhs: $1.1, rhsID: $1.0)
    }).map { $0.1 }
  }

  func digest(annum: AnnumID) -> AnnumDigest? {
    lookup.annumDigest(id: annum)
  }

  func digest(artist: ID) -> ArtistDigest? {
    lookup.artistDigest(id: artist)
  }

  func digest(venue: ID) -> VenueDigest? {
    lookup.venueDigest(id: venue)
  }

  func digest(show: ID) -> ShowDigest? {
    lookup.showDigest(showId: show)
  }

  func concert(show: ID) -> Concert? {
    lookup.concert(showId: show)
  }

  func venueIDs() -> [(ID, Venue)] {
    lookup.venueMap.map { ($0, $1) }
  }

  func artistIDs() -> [(ID, Artist)] {
    lookup.artistMap.map { ($0, $1) }
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
