//
//  Vault.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

extension Concert {
  fileprivate var digest: ShowDigest {
    ShowDigest(
      id: archivePath, date: show.date, performers: performers, venue: venue?.name,
      location: venue?.location)
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

  public init(music: Music, url: URL) async throws {
    var signpost = Signpost(category: "vault", name: "process")
    signpost.start()

    async let asyncLookup = await Lookup(music: music, identifier: BasicIdentifier())
    let lookup = try await asyncLookup
    async let asyncComparator = LibraryComparator(tokenMap: lookup.librarySortTokenMap)
    async let sectioner = await LibrarySectioner<String>(
      librarySortTokenMap: lookup.librarySortTokenMap)

    let comparator = await asyncComparator

    async let decadesMap = lookup.decadesMap

    async let asyncSortedConcerts = music.shows.map {
      Concert(show: $0, venue: lookup.venueForShow($0), artists: lookup.artistsForShow($0))
    }.sorted(by: comparator.compare(lhs:rhs:))

    let sortedConcerts = await asyncSortedConcerts

    async let artistDigests = music.artists.map { artist in
      ArtistDigest(
        artist: artist,
        shows: sortedConcerts.compactMap {
          guard $0.show.artists.contains(artist.id) else { return nil }
          return $0.digest
        },
        related: lookup.related(artist).sorted(by: { $0.name < $1.name }),
        rank: lookup.rankDigest(artist: artist.id))
    }

    async let venueDigests = music.venues.map { venue in
      VenueDigest(
        venue: venue,
        shows: sortedConcerts.compactMap {
          guard $0.show.venue == venue.id else { return nil }
          return $0.digest
        },
        related: lookup.related(venue).sorted(by: { $0.name < $1.name }),
        rank: lookup.rankDigest(venue: venue.id))
    }

    self.comparator = comparator
    self.sectioner = await sectioner
    self.rootURL = url

    self.concertMap = sortedConcerts.reduce(into: [:]) { $0[$1.id] = $1 }

    self.artistDigestMap = await artistDigests.reduce(into: [:]) { $0[$1.artist.id] = $1 }

    self.venueDigestMap = await venueDigests.reduce(into: [:]) { $0[$1.venue.id] = $1 }

    self.decadesMap = await decadesMap
    self.annumDigestMap = self.decadesMap.values.flatMap { $0.keys }.map { annum in
      AnnumDigest(
        annum: annum,
        shows: sortedConcerts.compactMap {
          guard $0.show.date.annum == annum else { return nil }
          return $0.digest
        },
        rank: lookup.rankDigest(annum: annum)
      )
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
