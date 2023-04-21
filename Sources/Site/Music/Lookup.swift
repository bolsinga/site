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

  let artistMap: [Artist.ID: Artist]
  let showMap: [Show.ID: Show]
  let venueMap: [Venue.ID: Venue]

  public init(music: Music) {
    // non-parallel, used for Previews, tests
    self.init(
      music: music,
      artistMap: createLookup(music.artists),
      showMap: createLookup(music.shows),
      venueMap: createLookup(music.venues))
  }

  internal init(
    music: Music,
    artistMap: [Artist.ID: Artist],
    showMap: [Show.ID: Show],
    venueMap: [Venue.ID: Venue]
  ) {
    self.music = music
    self.artistMap = artistMap
    self.showMap = showMap
    self.venueMap = venueMap
  }

  public static func create(music: Music) async -> Lookup {
    // parallel
    async let artistLookup = createLookup(music.artists)
    async let showLookup = createLookup(music.shows)
    async let venueLookup = createLookup(music.venues)

    let (artistMap, showMap, venueMap) = await (artistLookup, showLookup, venueLookup)

    return Lookup(
      music: music,
      artistMap: artistMap,
      showMap: showMap,
      venueMap: venueMap)
  }

  enum LookupError: Error {
    case missingVenue(Show)
    case missingArtist(Show, String)
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
