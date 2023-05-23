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
  let artistMap: [Artist.ID: Artist]
  let showMap: [Show.ID: Show]
  let venueMap: [Venue.ID: Venue]
  let artistRankings: Music.ArtistRankings
  let artistRankingMap: Music.ArtistRankingMap

  public init(music: Music) {
    // non-parallel, used for Previews, tests
    let artistRanks = music.artistRankings

    self.init(
      artistMap: createLookup(music.artists),
      showMap: createLookup(music.shows),
      venueMap: createLookup(music.venues),
      artistRankings: artistRanks.0,
      artistRankingMap: artistRanks.1)
  }

  internal init(
    artistMap: [Artist.ID: Artist],
    showMap: [Show.ID: Show],
    venueMap: [Venue.ID: Venue],
    artistRankings: Music.ArtistRankings,
    artistRankingMap: Music.ArtistRankingMap
  ) {
    self.artistMap = artistMap
    self.showMap = showMap
    self.venueMap = venueMap
    self.artistRankings = artistRankings
    self.artistRankingMap = artistRankingMap
  }

  public static func create(music: Music) async -> Lookup {
    // parallel
    async let artistLookup = createLookup(music.artists)
    async let showLookup = createLookup(music.shows)
    async let venueLookup = createLookup(music.venues)
    async let artistRanks = music.artistRankings

    let (artistMap, showMap, venueMap, artistRankings) = await (
      artistLookup, showLookup, venueLookup, artistRanks
    )

    return Lookup(
      artistMap: artistMap,
      showMap: showMap,
      venueMap: venueMap,
      artistRankings: artistRankings.0,
      artistRankingMap: artistRankings.1)
  }

  enum LookupError: Error {
    case missingVenue(Show)
    case missingArtist(Show, String)
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

  public func artistsWithShows(_ shows: [Show]) -> [Artist] {
    return Set(shows.reduce(into: []) { $0 += $1.artists }).compactMap { artistMap[$0] }
  }

  func showRank(artist: Artist) -> Music.Rank {
    artistRankingMap[artist.id] ?? (0, 0)
  }
}
