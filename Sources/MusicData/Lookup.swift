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

extension Music {
  fileprivate var librarySortTokenMap: [String: String] {
    let tokenizer = LibraryCompareTokenizer()
    return artists.reduce(
      into: venues.reduce(into: [:]) {
        $0[$1.id] = tokenizer.removeCommonInitialPunctuation($1.librarySortString)
      }
    ) {
      $0[$1.id] = tokenizer.removeCommonInitialPunctuation($1.librarySortString)
    }
  }
}

public struct Lookup: Sendable {
  let artistMap: [Artist.ID: Artist]
  let venueMap: [Venue.ID: Venue]
  let librarySortTokenMap: [String: String]  // String ID : tokenized LibraryComparable name for fast sorting.
  private let artistRankingMap: [Artist.ID: Ranking]
  private let venueRankingMap: [Venue.ID: Ranking]
  private let artistShowSpanRankingMap: [Artist.ID: Ranking]
  private let venueShowSpanRankingMap: [Venue.ID: Ranking]
  private let artistVenueRankingMap: [Artist.ID: Ranking]
  private let venueArtistRankingMap: [Venue.ID: Ranking]
  private let annumShowRankingMap: [Annum: Ranking]
  private let annumVenueRankingMap: [Annum: Ranking]
  private let annumArtistRankingMap: [Annum: Ranking]
  public let decadesMap: [Decade: [Annum: [Show.ID]]]
  private let artistFirstSetsMap: [Artist.ID: FirstSet]
  private let venueFirstSetsMap: [Venue.ID: FirstSet]
  private let relationMap: [String: [String]]  // Artist/Venue ID : [Artist/Venue ID]

  public init(music: Music) async {
    async let artistLookup = createLookup(music.artists)
    async let venueLookup = createLookup(music.venues)
    async let librarySortTokenMap = music.librarySortTokenMap
    async let artistRanks = music.artistRankings
    async let venueRanks = music.venueRankings
    async let artistSpanRanks = music.artistSpanRankings
    async let venueSpanRanks = music.venueSpanRankings
    async let artistVenueRanks = music.artistVenueRankings
    async let venueArtistRanks = music.venueArtistRankings
    async let annumShowRanks = music.annumShowRankings
    async let annumVenueRanks = music.annumVenueRankings
    async let annumArtistRanks = music.annumArtistRankings
    async let decades = music.decadesMap
    async let artistFirsts = music.artistFirstSets
    async let venueFirsts = music.venueFirstSets
    async let relations = music.relationMap

    self.artistMap = await artistLookup
    self.venueMap = await venueLookup
    self.librarySortTokenMap = await librarySortTokenMap
    self.artistRankingMap = await artistRanks
    self.venueRankingMap = await venueRanks
    self.artistShowSpanRankingMap = await artistSpanRanks
    self.venueShowSpanRankingMap = await venueSpanRanks
    self.artistVenueRankingMap = await artistVenueRanks
    self.venueArtistRankingMap = await venueArtistRanks
    self.annumShowRankingMap = await annumShowRanks
    self.annumVenueRankingMap = await annumVenueRanks
    self.annumArtistRankingMap = await annumArtistRanks
    self.decadesMap = await decades
    self.artistFirstSetsMap = await artistFirsts
    self.venueFirstSetsMap = await venueFirsts
    self.relationMap = await relations
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

  public func showRank(annum: Annum) -> Ranking {
    annumShowRankingMap[annum] ?? .empty
  }

  public func venueRank(annum: Annum) -> Ranking {
    annumVenueRankingMap[annum] ?? .empty
  }

  public func artistRank(annum: Annum) -> Ranking {
    annumArtistRankingMap[annum] ?? .empty
  }

  public func firstSet(artist: Artist) -> FirstSet {
    return artistFirstSetsMap[artist.id] ?? FirstSet.empty
  }

  public func firstSet(venue: Venue) -> FirstSet {
    return venueFirstSetsMap[venue.id] ?? FirstSet.empty
  }

  public func related(_ item: Venue) -> [Related] {
    relationMap[item.id]?.compactMap { venueMap[$0] }.map {
      Related(id: $0.archivePath, name: $0.name)
    } ?? []
  }

  public func related(_ item: Artist) -> [Related] {
    relationMap[item.id]?.compactMap { artistMap[$0] }.map {
      Related(id: $0.archivePath, name: $0.name)
    } ?? []
  }
}
