//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

extension Annum {
  fileprivate func digest(sortedConcerts: [Concert], lookup: Lookup<BasicIdentifier>) -> AnnumDigest
  {
    AnnumDigest(
      annum: self,
      shows: sortedConcerts.compactMap {
        guard $0.show.date.annum == self else { return nil }
        return $0.digest
      },
      rank: lookup.rankDigest(annum: self)
    )
  }
}

extension Artist {
  fileprivate func digest(sortedConcerts: [Concert], lookup: Lookup<BasicIdentifier>)
    -> ArtistDigest
  {
    ArtistDigest(
      artist: self,
      shows: sortedConcerts.compactMap {
        guard $0.show.artists.contains(id) else { return nil }
        return $0.digest
      },
      related: lookup.related(self),
      rank: lookup.rankDigest(artist: self.id))
  }
}

extension Concert {
  fileprivate var digest: ShowDigest {
    ShowDigest(
      id: archivePath, date: show.date, performers: performers, venue: venue?.name,
      location: venue?.location)
  }
}

extension Show {
  fileprivate func concert(lookup: Lookup<BasicIdentifier>) -> Concert {
    Concert(show: self, venue: lookup.venueForShow(self), artists: lookup.artistsForShow(self))
  }
}

extension Venue {
  fileprivate func digest(sortedConcerts: [Concert], lookup: Lookup<BasicIdentifier>) -> VenueDigest
  {
    VenueDigest(
      venue: self,
      shows: sortedConcerts.compactMap {
        guard $0.show.venue == id else { return nil }
        return $0.digest
      },
      related: lookup.related(self),
      rank: lookup.rankDigest(venue: self.id))
  }
}

public struct Vault: Sendable {
  public let comparator: LibraryComparator<String>
  public let sectioner: LibrarySectioner<String>
  public let rootURL: URL
  public let concertMap: [Concert.ID: Concert]

  public let artistDigestMap: [Artist.ID: ArtistDigest]

  public let venueDigestMap: [Venue.ID: VenueDigest]

  public let decadesMap: [Decade: [Annum: Set<Show.ID>]]
  public let annumDigestMap: [Annum: AnnumDigest]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let concertDayMap: [Int: Set<Concert.ID>]

  public init(music: Music, url: URL) async {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    async let asyncLookup = await Lookup(music: music, identifier: BasicIdentifier())
    let lookup = await asyncLookup
    async let asyncComparator = LibraryComparator(tokenMap: lookup.librarySortTokenMap)
    async let sectioner = await LibrarySectioner<String>(
      librarySortTokenMap: lookup.librarySortTokenMap)

    let comparator = await asyncComparator

    async let decadesMap = lookup.decadesMap

    async let asyncSortedConcerts = music.shows.map { $0.concert(lookup: lookup) }.sorted(
      by: comparator.compare(lhs:rhs:))

    let sortedConcerts = await asyncSortedConcerts

    async let artistDigests = music.artists.map {
      $0.digest(sortedConcerts: sortedConcerts, lookup: lookup)
    }

    async let venueDigests = music.venues.map {
      $0.digest(sortedConcerts: sortedConcerts, lookup: lookup)
    }

    self.comparator = comparator
    self.sectioner = await sectioner
    self.rootURL = url

    self.concertMap = sortedConcerts.reduce(into: [:]) { $0[$1.id] = $1 }

    self.artistDigestMap = await artistDigests.reduce(into: [:]) { $0[$1.artist.id] = $1 }

    self.venueDigestMap = await venueDigests.reduce(into: [:]) { $0[$1.venue.id] = $1 }

    self.decadesMap = await decadesMap
    self.annumDigestMap = self.decadesMap.values.flatMap { $0.keys }.map {
      $0.digest(sortedConcerts: sortedConcerts, lookup: lookup)
    }.reduce(into: [:]) { $0[$1.annum] = $1 }

    self.categoryURLLookup = ArchiveCategory.allCases.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: url) else { return }
      $0[$1] = url
    }

    self.concertDayMap = lookup.concertDayMap
  }

  func concerts(on dayOfLeapYear: Int) -> [Concert] {
    let concertIDs = concertDayMap[dayOfLeapYear] ?? []
    return concertIDs.compactMap { concertMap[$0] }.sorted { comparator.compare(lhs: $0, rhs: $1) }
  }

  /// The URL for this category.
  public func url(for category: ArchiveCategory) -> URL? {
    categoryURLLookup[category]
  }

  public func url(for item: PathRestorable) -> URL? {
    item.archivePath.url(using: rootURL)
  }

  func artists(filteredBy searchString: String) -> [Artist] {
    artistDigestMap.values.map { $0.artist }.names(filteredBy: searchString, additive: true).sorted(
      by: comparator.libraryCompare(lhs:rhs:))
  }

  func venues(filteredBy searchString: String) -> [Venue] {
    venueDigestMap.values.map { $0.venue }.names(filteredBy: searchString, additive: true).sorted(
      by: comparator.libraryCompare(lhs:rhs:))
  }
}
