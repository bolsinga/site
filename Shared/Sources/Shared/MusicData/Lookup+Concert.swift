//
//  Lookup+Concert.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/20/26.
//

import Foundation

extension Lookup {
  fileprivate func showDigest(show: Show, showId: ID) -> ShowDigest? {
    guard let venueID = venues(showID: showId), let venue = venueMap[venueID] else { return nil }
    let artists = artists(showID: showId).compactMap { id in artistMap[id].map { (id, $0) } }
    let performers = artists.map { ArchiveItem(id: $1.archivePath, name: $1.name) }
    let firstTimeArtistIDs = Set(
      artists.filter { rankDigest(artist: $0.0).firstSet.isFirst(on: show.date) }
        .map { $1.archivePath })
    let mostRecentArtistIDs = Set(
      artists.filter { rankDigest(artist: $0.0).mostRecentSet.isMostRecent(on: show.date) }
        .map { $1.archivePath })
    return ShowDigest(
      id: show.archivePath,
      date: show.date,
      performers: performers,
      venue: venue.name,
      venueID: venue.archivePath,
      location: venue.location,
      comment: show.comment,
      firstTimeArtistIDs: firstTimeArtistIDs,
      isFirstTimeVenue: rankDigest(venue: venueID).firstSet.isFirst(on: show.date),
      mostRecentArtistIDs: mostRecentArtistIDs,
      isMostRecentVenue: rankDigest(venue: venueID).mostRecentSet.isMostRecent(on: show.date))
  }

  func showDigest(showId: ID) -> ShowDigest? {
    guard let show = showMap[showId] else { return nil }
    return showDigest(show: show, showId: showId)
  }

  fileprivate func showDigests(annumID: AnnumID) -> [ShowDigest] {
    let showIDs = annumShows[annumID] ?? []
    return showIDs.compactMap { showDigest(showId: $0) }
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

  func annumDigest(id annumID: AnnumID) -> AnnumDigest? {
    guard let annum = annumMap[annumID] else { return nil }
    return AnnumDigest(
      annum: annum, shows: showDigests(annumID: annumID), rank: rankDigest(annum: annumID),
      newArtistCount: newArtistCount(in: annum), newVenueCount: newVenueCount(in: annum),
      mostRecentArtistCount: mostRecentArtistCount(in: annum),
      mostRecentVenueCount: mostRecentVenueCount(in: annum))
  }
}
