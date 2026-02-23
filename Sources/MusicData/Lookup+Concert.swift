//
//  Lookup+Concert.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/20/26.
//

import Foundation

extension Concert {
  fileprivate var digest: ShowDigest {
    ShowDigest(
      id: archivePath, date: show.date, performers: performers, venue: venue.name,
      location: venue.location)
  }
}

extension Lookup {
  func sortedConcerts(comparator: LibraryComparator<ID>) -> [Concert] {
    showMap.values.compactMap {
      guard let venue = venueForShow($0) else { return nil }
      return Concert(show: $0, venue: venue, artists: artistsForShow($0))
    }.sorted(by: { compareConcerts(lhs: $0, rhs: $1, comparator: comparator) })
  }

  func artistDigestMap(sortedConcerts: [Concert]) throws -> [ID: ArtistDigest] {
    try artistMap.values.map { artist in
      ArtistDigest(
        artist: artist,
        shows: sortedConcerts.compactMap {
          guard $0.show.artists.contains(artist.id) else { return nil }
          return $0.digest
        },
        related: related(artist).sorted(by: { $0.name < $1.name }),
        rank: rankDigest(artist: try identifier.artist(artist.id)))
    }.reduce(into: [:]) {
      $0[try identifier.artist($1.artist.id)] = $1
    }
  }

  func venueDigestMap(sortedConcerts: [Concert]) throws -> [ID: VenueDigest] {
    try venueMap.values.map { venue in
      VenueDigest(
        venue: venue,
        shows: sortedConcerts.compactMap {
          guard $0.show.venue == venue.id else { return nil }
          return $0.digest
        },
        related: related(venue).sorted(by: { $0.name < $1.name }),
        rank: rankDigest(venue: try identifier.venue(venue.id)))
    }.reduce(into: [:]) {
      $0[try identifier.venue($1.venue.id)] = $1
    }
  }

  func annumDigestMap(sortedConcerts: [Concert]) throws -> [AnnumID: AnnumDigest] {
    let annums = decadesMap.values.flatMap { $0.keys.map { identifier.annum(for: $0) } }
    return try annums.map { annum in
      AnnumDigest(
        annum: annum,
        shows: sortedConcerts.compactMap {
          guard $0.show.date.annum == annum else { return nil }
          return $0.digest
        },
        rank: rankDigest(annum: try identifier.annum(annum))
      )
    }.reduce(into: [:]) { $0[try identifier.annum($1.annum)] = $1 }
  }
}
