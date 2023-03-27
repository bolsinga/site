//
//  Music+Lookup.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation

extension Music {
  enum LookupError: Error {
    case missingVenue(Show)
    case missingArtist(Show, String)
    case missingAlbum(Artist, String)
  }

  public func venueForShow(_ show: Show) throws -> Venue {
    guard let venue = venueMap[show.venue] else {
      throw LookupError.missingVenue(show)
    }
    return venue
  }

  public func artistsForShow(_ show: Show) throws -> [Artist] {
    var showArtists = [Artist]()
    for id in show.artists {
      guard let artist = artistMap[id] else {
        throw LookupError.missingArtist(show, id)
      }
      showArtists.append(artist)
    }
    return showArtists
  }

  public func artistForAlbum(_ album: Album) -> Artist? {
    if let id = album.performer {
      return artistMap[id]
    }
    return nil
  }

  public func albumsForArtist(_ artist: Artist) throws -> [Album] {
    var artistAlbums = [Album]()
    for id in artist.albums ?? [] {
      guard let album = albumMap[id] else {
        throw LookupError.missingAlbum(artist, id)
      }
      artistAlbums.append(album)
    }
    return artistAlbums
  }

  public func showsForArtist(_ artist: Artist) -> [Show] {
    shows.filter { $0.artists.contains(artist.id) }
  }

  public func showsForVenue(_ venue: Venue) -> [Show] {
    shows.filter { $0.venue == venue.id }
  }

  public func artistsForVenue(_ venue: Venue) -> [Artist] {
    return Set(showsForVenue(venue).reduce(into: []) { $0 += $1.artists }).compactMap {
      artistMap[$0]
    }
  }

  public func showsForYear(_ year: Int) -> [Show] {
    shows.filter { $0.date.normalizedYear == year }
  }

  public func artistsWithShows() -> [Artist] {
    return Set(shows.reduce(into: []) { $0 += $1.artists }).compactMap { artistMap[$0] }
  }
}
