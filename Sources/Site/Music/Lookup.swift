//
//  Lookup.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation

private func createLookup<T: Identifiable>(_ sequence: [T]) -> [T.ID: T] {
  sequence.reduce(into: [:]) { $0[$1.id] = $1 }
}

public struct Lookup {
  let music: Music

  let albumMap: [Album.ID: Album]
  let artistMap: [Artist.ID: Artist]
  let relationMap: [Relation.ID: Relation]
  let showMap: [Show.ID: Show]
  let songMap: [Song.ID: Song]
  let venueMap: [Venue.ID: Venue]

  public init(music: Music) {
    self.music = music

    albumMap = createLookup(music.albums)
    artistMap = createLookup(music.artists)
    relationMap = createLookup(music.relations)
    showMap = createLookup(music.shows)
    songMap = createLookup(music.songs)
    venueMap = createLookup(music.venues)
  }

  enum LookupError: Error {
    case missingVenue(Show)
    case missingArtist(Show, String)
    case missingAlbum(Artist, String)
  }

  private var shows: [Show] {
    music.shows
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

  public func showsForYear(_ year: PartialDate) -> [Show] {
    shows.filter { $0.date.normalizedYear == year.normalizedYear }
  }

  public func artistsWithShows() -> [Artist] {
    return Set(shows.reduce(into: []) { $0 += $1.artists }).compactMap { artistMap[$0] }
  }
}
