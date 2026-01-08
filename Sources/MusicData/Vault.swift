//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

extension Annum {
  fileprivate func digest(sortedConcerts: [Concert], lookup: Lookup) -> AnnumDigest {
    AnnumDigest(
      annum: self,
      shows: sortedConcerts.filter { $0.show.date.annum == self }.map { $0.digest },
      showRank: lookup.showRank(annum: self),
      venueRank: lookup.venueRank(annum: self),
      artistRank: lookup.artistRank(annum: self)
    )
  }
}

extension Artist {
  fileprivate func digest(sortedConcerts: [Concert], lookup: Lookup) -> ArtistDigest {
    ArtistDigest(
      artist: self,
      shows: sortedConcerts.filter { $0.show.artists.contains(id) }.map { $0.digest },
      related: lookup.related(self),
      firstSet: lookup.firstSet(artist: self),
      spanRank: lookup.spanRank(artist: self),
      showRank: lookup.showRank(artist: self),
      venueRank: lookup.artistVenueRank(artist: self))
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
  fileprivate func concert(lookup: Lookup) -> Concert {
    Concert(show: self, venue: lookup.venueForShow(self), artists: lookup.artistsForShow(self))
  }
}

extension Venue {
  fileprivate func digest(sortedConcerts: [Concert], lookup: Lookup) -> VenueDigest {
    VenueDigest(
      venue: self,
      shows: sortedConcerts.filter { $0.show.venue == id }.map { $0.digest },
      related: lookup.related(self),
      firstSet: lookup.firstSet(venue: self),
      spanRank: lookup.spanRank(venue: self),
      showRank: lookup.venueRank(venue: self),
      venueArtistRank: lookup.venueArtistRank(venue: self))
  }
}

public struct Vault: Sendable {
  public let comparator: LibraryComparator
  public let sectioner: LibrarySectioner
  public let rootURL: URL
  public let concertMap: [Concert.ID: Concert]

  public let artistDigestMap: [Artist.ID: ArtistDigest]

  public let venueDigestMap: [Venue.ID: VenueDigest]

  public let decadesMap: [Decade: [Annum: [Show.ID]]]
  public let annumDigestMap: [Annum: AnnumDigest]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let concertDayMap: [Int: [Concert.ID]]

  public init(music: Music, url: URL) async {
    async let asyncLookup = await Lookup(music: music)
    let lookup = await asyncLookup
    async let asyncComparator = LibraryComparator(tokenMap: lookup.librarySortTokenMap)
    async let sectioner = await LibrarySectioner(librarySortTokenMap: lookup.librarySortTokenMap)

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

    self.concertDayMap = sortedConcerts.reduce(into: [Int: [Concert.ID]]()) {
      guard !$1.show.date.isPartiallyUnknown else { return }
      guard let date = $1.show.date.date else { return }

      let dayOfLeapYear = date.dayOfLeapYear

      var arr = $0[dayOfLeapYear] ?? []
      arr.append($1.id)
      $0[dayOfLeapYear] = arr
    }
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
}
