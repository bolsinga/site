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

  private let categoryURLLookup: [ArchiveCategory: URL]

  public init(music: Music, url: URL) {
    // non-parallel, used for previews, tests
    let lookup = Lookup(music: music)
    let comparator = LibraryComparator()

    let concerts = music.shows.concerts(
      rootURL: url, lookup: lookup, comparator: comparator.compare(lhs:rhs:))
    let artistDigests = music.artists.digests(
      concerts: concerts, rootURL: url, lookup: lookup, comparator: comparator.compare(lhs:rhs:)
    )
    let venueDigests = music.venues.digests(
      concerts: concerts, rootURL: url, lookup: lookup, comparator: comparator.compare(lhs:rhs:)
    )
    let decadesMap = lookup.decadesMap

    self.init(
      comparator: comparator, sectioner: LibrarySectioner(), rootURL: url,
      concerts: concerts, artistDigests: artistDigests, venueDigests: venueDigests,
      decadesMap: decadesMap)
  }

  internal init(
    comparator: LibraryComparator, sectioner: LibrarySectioner,
    rootURL: URL, concerts: [Concert], artistDigests: [ArtistDigest], venueDigests: [VenueDigest],
    decadesMap: [Decade: [Annum: [Show.ID]]]
  ) {
    self.comparator = comparator
    self.sectioner = sectioner
    self.rootURL = rootURL

    self.concerts = concerts
    self.concertMap = self.concerts.reduce(into: [:]) { $0[$1.id] = $1 }

    self.artistDigests = artistDigests
    self.artistDigestMap = self.artistDigests.reduce(into: [:]) { $0[$1.artist.id] = $1 }

    self.venueDigests = venueDigests
    self.venueDigestMap = self.venueDigests.reduce(into: [:]) { $0[$1.venue.id] = $1 }

    self.decadesMap = decadesMap

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: rootURL) else { return }
      $0[$1] = url
    }
  }

  public static func create(music: Music, url: URL) async -> Vault {
    async let asyncLookup = await Lookup.create(music: music)
    async let asyncComparator = await LibraryComparator.create(music: music)
    async let sectioner = await LibrarySectioner.create(music: music)

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

    let v = Vault(
      comparator: comparator, sectioner: await sectioner, rootURL: url,
      concerts: concerts, artistDigests: await artistDigests, venueDigests: await venueDigests,
      decadesMap: await decadesMap)

    return v
  }

  public func concerts(on date: Date) -> [Concert] {
    return concerts.filter { $0.show.date.day != nil }
      .filter { $0.show.date.month != nil }
      .filter {
        Calendar.autoupdatingCurrent.date(
          date,
          matchesComponents: DateComponents(month: $0.show.date.month!, day: $0.show.date.day!))
      }
      .sorted { comparator.compare(lhs: $0, rhs: $1) }
  }

  func concerts(during annum: Annum) -> [Concert] {
    var result: [Concert] = []
    for id in decadesMap[annum.decade]?[annum] ?? [] {
      result += concerts.filter { $0.id == id }
    }
    return result.sorted { comparator.compare(lhs: $0, rhs: $1) }
  }

  /// The URL for this category.
  public func url(for category: ArchiveCategory) -> URL? {
    categoryURLLookup[category]
  }
}
