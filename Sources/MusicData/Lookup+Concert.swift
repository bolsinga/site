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

  fileprivate func concert(show: Show) -> Concert? {
    guard let venue = venueForShow(show) else { return nil }
    return Concert(show: show, venue: venue, artists: artistsForShow(show))
  }

  func concert(showId: ID) -> Concert? {
    guard let show = showMap[showId] else { return nil }
    return concert(show: show)
  }

  private func artistDigest(artist: Artist, artistID: ID) -> ArtistDigest {
    ArtistDigest(
      artist: artist,
      shows: shows(artistID: artistID).compactMap { showDigest(showId: $0) },
      related: related(artistID: artistID).sorted(by: { $0.name < $1.name }),
      rank: rankDigest(artist: artistID))
  }

  func artistDigest(id artistID: ID) -> ArtistDigest? {
    guard let artist = artistMap[artistID] else { return nil }
    return artistDigest(artist: artist, artistID: artistID)
  }

  private func venueDigest(venue: Venue, venueID: ID) -> VenueDigest {
    VenueDigest(
      venue: venue,
      shows: shows(venueID: venueID).compactMap { showDigest(showId: $0) },
      related: related(venueID: venueID).sorted(by: { $0.name < $1.name }),
      rank: rankDigest(venue: venueID))
  }

  func venueDigest(id venueID: ID) -> VenueDigest? {
    guard let venue = venueMap[venueID] else { return nil }
    return venueDigest(venue: venue, venueID: venueID)
  }

  func annumDigest(annum: Annum) throws -> AnnumDigest {
    let annumID = try identifier.annum(annum)
    return AnnumDigest(
      annum: annum, shows: showDigests(annum: annum, annumID: annumID),
      rank: rankDigest(annum: annumID))
  }
}
