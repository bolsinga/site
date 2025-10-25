//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public struct Vault: Sendable {
  public let comparator: LibraryComparator
  public let sectioner: LibrarySectioner
  public let rootURL: URL
  public let concerts: [Concert]
  public let concertMap: [Concert.ID: Concert]

  public let artistDigests: [ArtistDigest]
  public let artistDigestMap: [Artist.ID: ArtistDigest]

  public let venueDigests: [VenueDigest]
  public let venueDigestMap: [Venue.ID: VenueDigest]

  public let decadesMap: [Decade: [Annum: [Show.ID]]]
  public let annumDigestMap: [Annum: AnnumDigest]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let concertDayMap: [Int: [Concert.ID]]

  public init(music: Music, url: URL) async {
    async let asyncLookup = await Lookup(music: music)
    async let asyncComparator = await LibraryComparator(music: music)
    async let sectioner = await LibrarySectioner(music: music)

    let lookup = await asyncLookup
    let comparator = await asyncComparator

    async let decadesMap = lookup.decadesMap

    async let asyncConcerts = music.shows.concerts(
      rootURL: url, lookup: lookup, comparator: comparator.compare(lhs:rhs:))

    let concerts = await asyncConcerts

    async let artistDigests = music.artists.digests(
      concerts: concerts, rootURL: url, lookup: lookup, comparator: comparator.compare(lhs:rhs:)
    )

    async let venueDigests = music.venues.digests(
      concerts: concerts, rootURL: url, lookup: lookup, comparator: comparator.compare(lhs:rhs:)
    )

    self.comparator = comparator
    self.sectioner = await sectioner
    self.rootURL = url

    self.concerts = concerts
    self.concertMap = self.concerts.reduce(into: [:]) { $0[$1.id] = $1 }

    self.artistDigests = await artistDigests
    self.artistDigestMap = self.artistDigests.reduce(into: [:]) { $0[$1.artist.id] = $1 }

    self.venueDigests = await venueDigests
    self.venueDigestMap = self.venueDigests.reduce(into: [:]) { $0[$1.venue.id] = $1 }

    self.decadesMap = await decadesMap
    self.annumDigestMap = self.decadesMap.values.flatMap { $0.keys }.digests(
      concerts: concerts, rootURL: url, lookup: lookup, comparator: comparator.compare(lhs:rhs:)
    ).reduce(into: [:]) { $0[$1.annum] = $1 }

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: url) else { return }
      $0[$1] = url
    }

    self.concertDayMap = self.concerts.reduce(into: [Int: [Concert.ID]]()) {
      guard !$1.show.date.isPartiallyUnknown else { return }
      guard let date = $1.show.date.date else { return }

      let dayOfLeapYear = date.dayOfLeapYear

      var arr = $0[dayOfLeapYear] ?? []
      arr.append($1.id)
      $0[dayOfLeapYear] = arr
    }
  }

  public var concertsToday: [Concert] {
    concerts(on: Date.now.dayOfLeapYear)
  }

  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    let concertIDs = concertDayMap[dayOfLeapYear] ?? []
    return concertIDs.compactMap { concertMap[$0] }.sorted { comparator.compare(lhs: $0, rhs: $1) }
  }

  /// The URL for this category.
  public func url(for category: ArchiveCategory) -> URL? {
    categoryURLLookup[category]
  }
}
