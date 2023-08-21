//
//  Lookup.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation
import os

extension Logger {
  static let lookup = Logger(category: "lookup")
}

private func createLookup<T: Identifiable>(_ sequence: [T]) -> [T.ID: T] {
  sequence.reduce(into: [:]) { $0[$1.id] = $1 }
}

public struct Lookup {
  let artistMap: [Artist.ID: Artist]
  let showMap: [Show.ID: Show]
  let venueMap: [Venue.ID: Venue]
  let artistRankingMap: [Artist.ID: Ranking]
  let venueRankingMap: [Venue.ID: Ranking]
  let artistShowSpanRankingMap: [Artist.ID: Ranking]
  let venueShowSpanRankingMap: [Venue.ID: Ranking]
  let artistVenueRankingMap: [Artist.ID: Ranking]
  let venueArtistRankingMap: [Venue.ID: Ranking]
  let decadesMap: [Decade: [Annum: [Show]]]
  let artistFirstSetsMap: [Artist.ID: FirstSet]
  let venueFirstSetsMap: [Venue.ID: FirstSet]

  public init(music: Music) {
    // non-parallel, used for Previews, tests
    let artistRanks = music.artistRankings
    let venueRanks = music.venueRankings
    let artistSpanRanks = music.artistSpanRankings
    let venueSpanRanks = music.venueSpanRankings
    let artistVenueRanks = music.artistVenueRankings
    let venueArtistRanks = music.venueArtistRankings
    let decadesMap = music.decadesMap
    let artistFirstSets = music.artistFirstSets
    let venueFirstSets = music.venueFirstSets

    self.init(
      artistMap: createLookup(music.artists),
      showMap: createLookup(music.shows),
      venueMap: createLookup(music.venues),
      artistRankingMap: artistRanks,
      venueRankingMap: venueRanks,
      artistShowSpanRankingMap: artistSpanRanks,
      venueShowSpanRankingMap: venueSpanRanks,
      artistVenueRankingMap: artistVenueRanks,
      venueArtistRankingMap: venueArtistRanks,
      decadesMap: decadesMap,
      artistFirstSetsMap: artistFirstSets,
      venueFirstSetsMap: venueFirstSets)
  }

  internal init(
    artistMap: [Artist.ID: Artist],
    showMap: [Show.ID: Show],
    venueMap: [Venue.ID: Venue],
    artistRankingMap: [Artist.ID: Ranking],
    venueRankingMap: [Venue.ID: Ranking],
    artistShowSpanRankingMap: [Artist.ID: Ranking],
    venueShowSpanRankingMap: [Venue.ID: Ranking],
    artistVenueRankingMap: [Artist.ID: Ranking],
    venueArtistRankingMap: [Venue.ID: Ranking],
    decadesMap: [Decade: [Annum: [Show]]],
    artistFirstSetsMap: [Artist.ID: FirstSet],
    venueFirstSetsMap: [Venue.ID: FirstSet]
  ) {
    self.artistMap = artistMap
    self.showMap = showMap
    self.venueMap = venueMap
    self.artistRankingMap = artistRankingMap
    self.venueRankingMap = venueRankingMap
    self.artistShowSpanRankingMap = artistShowSpanRankingMap
    self.venueShowSpanRankingMap = venueShowSpanRankingMap
    self.artistVenueRankingMap = artistVenueRankingMap
    self.venueArtistRankingMap = venueArtistRankingMap
    self.decadesMap = decadesMap
    self.artistFirstSetsMap = artistFirstSetsMap
    self.venueFirstSetsMap = venueFirstSetsMap
  }

  public static func create(music: Music) async -> Lookup {
    // parallel
    async let artistLookup = createLookup(music.artists)
    async let showLookup = createLookup(music.shows)
    async let venueLookup = createLookup(music.venues)
    async let artistRanks = music.artistRankings
    async let venueRanks = music.venueRankings
    async let artistSpanRanks = music.artistSpanRankings
    async let venueSpanRanks = music.venueSpanRankings
    async let artistVenueRanks = music.artistVenueRankings
    async let venueArtistRanks = music.venueArtistRankings
    async let decades = music.decadesMap
    async let artistFirsts = music.artistFirstSets
    async let venueFirsts = music.venueFirstSets

    let (
      artistMap, showMap, venueMap, artistRankings, venueRankings, artistSpanRankings,
      venueSpanRankings, artistVenueRankings, venueArtistRankings, decadesMap, artistFirstSets,
      venueFirstSets
    ) = await (
      artistLookup, showLookup, venueLookup, artistRanks, venueRanks, artistSpanRanks,
      venueSpanRanks, artistVenueRanks, venueArtistRanks, decades, artistFirsts, venueFirsts
    )

    return Lookup(
      artistMap: artistMap,
      showMap: showMap,
      venueMap: venueMap,
      artistRankingMap: artistRankings,
      venueRankingMap: venueRankings,
      artistShowSpanRankingMap: artistSpanRankings,
      venueShowSpanRankingMap: venueSpanRankings,
      artistVenueRankingMap: artistVenueRankings,
      venueArtistRankingMap: venueArtistRankings,
      decadesMap: decadesMap,
      artistFirstSetsMap: artistFirstSets,
      venueFirstSetsMap: venueFirstSets)
  }

  public func venueForShow(_ show: Show) -> Venue? {
    guard let venue = venueMap[show.venue] else {
      Logger.lookup.log("Show: \(show.id) missing venue")
      return nil
    }
    return venue
  }

  public func artistsForShow(_ show: Show) -> [Artist] {
    var showArtists = [Artist]()
    for id in show.artists {
      guard let artist = artistMap[id] else {
        Logger.lookup.log("Show: \(show.id) missing artist: \(id)")
        continue
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

  func showRank(artist: Artist) -> Ranking {
    artistRankingMap[artist.id] ?? Ranking.empty
  }

  func venueRank(artist: Artist) -> Ranking {
    artistVenueRankingMap[artist.id] ?? Ranking.empty
  }

  func venueRank(venue: Venue) -> Ranking {
    venueRankingMap[venue.id] ?? Ranking.empty
  }

  func spanRank(artist: Artist) -> Ranking {
    artistShowSpanRankingMap[artist.id] ?? Ranking.empty
  }

  func spanRank(venue: Venue) -> Ranking {
    venueShowSpanRankingMap[venue.id] ?? Ranking.empty
  }

  func artistVenueRank(artist: Artist) -> Ranking {
    artistVenueRankingMap[artist.id] ?? Ranking.empty
  }

  func venueArtistRank(venue: Venue) -> Ranking {
    venueArtistRankingMap[venue.id] ?? Ranking.empty
  }

  func firstSet(artist: Artist) -> FirstSet {
    return artistFirstSetsMap[artist.id] ?? FirstSet.empty
  }

  func firstSet(venue: Venue) -> FirstSet {
    return venueFirstSetsMap[venue.id] ?? FirstSet.empty
  }
}
