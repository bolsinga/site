//
//  Lookup.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let lookup = Logger(category: "lookup")
}

private func createLookup<T: Identifiable>(_ sequence: [T]) -> [T.ID: T] {
  sequence.reduce(into: [:]) { $0[$1.id] = $1 }
}

public struct Lookup: Sendable {
  let artistMap: [Artist.ID: Artist]
  let venueMap: [Venue.ID: Venue]
  private let artistRankingMap: [Artist.ID: Ranking]
  private let venueRankingMap: [Venue.ID: Ranking]
  private let artistShowSpanRankingMap: [Artist.ID: Ranking]
  private let venueShowSpanRankingMap: [Venue.ID: Ranking]
  private let artistVenueRankingMap: [Artist.ID: Ranking]
  private let venueArtistRankingMap: [Venue.ID: Ranking]
  public let decadesMap: [Decade: [Annum: [Show.ID]]]
  private let artistFirstSetsMap: [Artist.ID: FirstSet]
  private let venueFirstSetsMap: [Venue.ID: FirstSet]
  private let relationMap: [String: [String]]  // Artist/Venue ID : [Artist/Venue ID]

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
    let relationMap = music.relationMap

    self.init(
      artistMap: createLookup(music.artists),
      venueMap: createLookup(music.venues),
      artistRankingMap: artistRanks,
      venueRankingMap: venueRanks,
      artistShowSpanRankingMap: artistSpanRanks,
      venueShowSpanRankingMap: venueSpanRanks,
      artistVenueRankingMap: artistVenueRanks,
      venueArtistRankingMap: venueArtistRanks,
      decadesMap: decadesMap,
      artistFirstSetsMap: artistFirstSets,
      venueFirstSetsMap: venueFirstSets,
      relationMap: relationMap)
  }

  internal init(
    artistMap: [Artist.ID: Artist],
    venueMap: [Venue.ID: Venue],
    artistRankingMap: [Artist.ID: Ranking],
    venueRankingMap: [Venue.ID: Ranking],
    artistShowSpanRankingMap: [Artist.ID: Ranking],
    venueShowSpanRankingMap: [Venue.ID: Ranking],
    artistVenueRankingMap: [Artist.ID: Ranking],
    venueArtistRankingMap: [Venue.ID: Ranking],
    decadesMap: [Decade: [Annum: [Show.ID]]],
    artistFirstSetsMap: [Artist.ID: FirstSet],
    venueFirstSetsMap: [Venue.ID: FirstSet],
    relationMap: [String: [String]]
  ) {
    self.artistMap = artistMap
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
    self.relationMap = relationMap
  }

  public static func create(music: Music) async -> Lookup {
    // parallel
    async let artistLookup = createLookup(music.artists)
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
    async let relations = music.relationMap

    let (
      artistMap, venueMap, artistRankings, venueRankings, artistSpanRankings,
      venueSpanRankings, artistVenueRankings, venueArtistRankings, decadesMap, artistFirstSets,
      venueFirstSets, relationMap
    ) = await (
      artistLookup, venueLookup, artistRanks, venueRanks, artistSpanRanks,
      venueSpanRanks, artistVenueRanks, venueArtistRanks, decades, artistFirsts, venueFirsts,
      relations
    )

    return Lookup(
      artistMap: artistMap,
      venueMap: venueMap,
      artistRankingMap: artistRankings,
      venueRankingMap: venueRankings,
      artistShowSpanRankingMap: artistSpanRankings,
      venueShowSpanRankingMap: venueSpanRankings,
      artistVenueRankingMap: artistVenueRankings,
      venueArtistRankingMap: venueArtistRankings,
      decadesMap: decadesMap,
      artistFirstSetsMap: artistFirstSets,
      venueFirstSetsMap: venueFirstSets,
      relationMap: relationMap)
  }

  public func venueForShow(_ show: Show) -> Venue? {
    guard let venue = venueMap[show.venue] else {
      Logger.lookup.log("Show: \(show.id, privacy: .public) missing venue")
      return nil
    }
    return venue
  }

  public func artistsForShow(_ show: Show) -> [Artist] {
    var showArtists = [Artist]()
    for id in show.artists {
      guard let artist = artistMap[id] else {
        Logger.lookup.log(
          "Show: \(show.id, privacy: .public) missing artist: \(id, privacy: .public)")
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

  public func showRank(artist: Artist) -> Ranking {
    artistRankingMap[artist.id] ?? Ranking.empty
  }

  public func venueRank(venue: Venue) -> Ranking {
    venueRankingMap[venue.id] ?? Ranking.empty
  }

  public func spanRank(artist: Artist) -> Ranking {
    artistShowSpanRankingMap[artist.id] ?? Ranking.empty
  }

  public func spanRank(venue: Venue) -> Ranking {
    venueShowSpanRankingMap[venue.id] ?? Ranking.empty
  }

  public func artistVenueRank(artist: Artist) -> Ranking {
    artistVenueRankingMap[artist.id] ?? Ranking.empty
  }

  public func venueArtistRank(venue: Venue) -> Ranking {
    venueArtistRankingMap[venue.id] ?? Ranking.empty
  }

  public func firstSet(artist: Artist) -> FirstSet {
    return artistFirstSetsMap[artist.id] ?? FirstSet.empty
  }

  public func firstSet(venue: Venue) -> FirstSet {
    return venueFirstSetsMap[venue.id] ?? FirstSet.empty
  }

  public func related(_ item: Venue) -> [Venue] {
    relationMap[item.id]?.compactMap { venueMap[$0] } ?? []
  }

  public func related(_ item: Artist) -> [Artist] {
    relationMap[item.id]?.compactMap { artistMap[$0] } ?? []
  }
}
