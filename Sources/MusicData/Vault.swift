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
  public let concertMap: [ID: Concert]

  public let artistDigestMap: [ID: ArtistDigest]

  public let venueDigestMap: [ID: VenueDigest]

  public let decadesMap: [Decade: [AnnumID: Set<ID>]]
  public let annumDigestMap: [AnnumID: AnnumDigest]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let concertDayMap: [Int: Set<ID>]

  private let lookup: Lookup<Identifier>

  public init(music: Music, url: URL, identifier: Identifier) async throws {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    async let asyncLookup = await Lookup(music: music, identifier: identifier)
    let lookup = try await asyncLookup
    self.lookup = lookup
    let comparator = LibraryComparator(tokenMap: lookup.librarySortTokenMap)

    async let asyncSortedConcerts = lookup.sortedConcerts(comparator: comparator)

    let sortedConcerts = await asyncSortedConcerts

    async let artistDigestMap = lookup.artistDigestMap(sortedConcerts: sortedConcerts)

    async let venueDigestMap = lookup.venueDigestMap(sortedConcerts: sortedConcerts)

    self.comparator = comparator
    self.sectioner = await LibrarySectioner(librarySortTokenMap: lookup.librarySortTokenMap)
    self.rootURL = url

    self.concertMap = try sortedConcerts.reduce(into: [:]) { $0[try identifier.show($1.id)] = $1 }

    self.artistDigestMap = try await artistDigestMap

    self.venueDigestMap = try await venueDigestMap

    self.decadesMap = lookup.decadesMap
    self.annumDigestMap = try lookup.annumDigestMap(sortedConcerts: sortedConcerts)

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: url) else { return }
      $0[$1] = url
    }

    self.concertDayMap = lookup.concertDayMap
  }

  fileprivate func unsortedConcerts(on dayOfLeapYear: Int) -> any Collection<Concert> {
    let concertIDs = concertDayMap[dayOfLeapYear] ?? []
    return concertIDs.compactMap { concertMap[$0] }
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

  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    unsortedConcerts(on: dayOfLeapYear).sorted(by: compare(lhs:rhs:))
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
    artistDigestMap.values.map { $0.artist }.names(filteredBy: searchString, additive: true)
      .sorted(by: compare(lhs:rhs:))
  }

  func venues(filteredBy searchString: String) -> [Venue] {
    venueDigestMap.values.map { $0.venue }.names(filteredBy: searchString, additive: true)
      .sorted(by: compare(lhs:rhs:))
  }
}
