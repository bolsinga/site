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
  fileprivate func showDigest(for show: Show) -> ShowDigest? {
    guard let venue = venueForShow(show) else { return nil }
    let performers = artistsForShow(show).map { $0.name }
    return ShowDigest(
      id: show.archivePath, date: show.date, performers: performers, venue: venue.name,
      location: venue.location)
  }

  fileprivate func showDigest(showId: ID) -> ShowDigest? {
    guard let show = showMap[showId] else { return nil }
    return showDigest(for: show)
  }

  fileprivate func showDigests(annum: Annum, annumID: AnnumID) -> [ShowDigest] {
    let showIDs = decadesMap[annum.decade]?[annumID] ?? []
    return showIDs.compactMap { showDigest(showId: $0) }
  }

  var concerts: [Concert] {
    showMap.values.compactMap {
      guard let venue = venueForShow($0) else { return nil }
      return Concert(show: $0, venue: venue, artists: artistsForShow($0))
    }
  }

  func artistDigestMap(concerts: [Concert]) throws -> [ID: ArtistDigest] {
    try artistMap.values.map { artist in
      ArtistDigest(
        artist: artist,
        shows: concerts.compactMap {
          guard $0.show.artists.contains(artist.id) else { return nil }
          return $0.digest
        },
        related: related(artist).sorted(by: { $0.name < $1.name }),
        rank: rankDigest(artist: try identifier.artist(artist.id)))
    }.reduce(into: [:]) {
      $0[try identifier.artist($1.artist.id)] = $1
    }
  }

  func venueDigestMap(concerts: [Concert]) throws -> [ID: VenueDigest] {
    try venueMap.values.map { venue in
      VenueDigest(
        venue: venue,
        shows: concerts.compactMap {
          guard $0.show.venue == venue.id else { return nil }
          return $0.digest
        },
        related: related(venue).sorted(by: { $0.name < $1.name }),
        rank: rankDigest(venue: try identifier.venue(venue.id)))
    }.reduce(into: [:]) {
      $0[try identifier.venue($1.venue.id)] = $1
    }
  }

  func annumDigest(annum: Annum) throws -> AnnumDigest {
    let annumID = try identifier.annum(annum)
    return AnnumDigest(
      annum: annum, shows: showDigests(annum: annum, annumID: annumID),
      rank: rankDigest(annum: annumID))
  }
}
