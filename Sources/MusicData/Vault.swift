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
      shows: sortedConcerts.compactMap {
        guard $0.show.date.annum == self else { return nil }
        return $0.digest
      },
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
      shows: sortedConcerts.compactMap {
        guard $0.show.artists.contains(id) else { return nil }
        return $0.digest
      },
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
      shows: sortedConcerts.compactMap {
        guard $0.show.venue == id else { return nil }
        return $0.digest
      },
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

  public let decadesMap: [Decade: [Annum: Set<Show.ID>]]
  public let annumDigestMap: [Annum: AnnumDigest]

  private let categoryURLLookup: [ArchiveCategory: URL]

  private let concertDayMap: [Int: Set<Concert.ID>]

  public init(music: Music, url: URL) async {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

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
}
