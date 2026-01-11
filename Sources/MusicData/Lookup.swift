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

public struct Lookup: Codable, Sendable {
  let artistMap: [Artist.ID: Artist]
  let venueMap: [Venue.ID: Venue]
  private let bracket: Bracket
  private let relationMap: [String: [String]]  // Artist/Venue ID : [Artist/Venue ID]

  public init(music: Music) async {
    async let artistLookup = createLookup(music.artists)
    async let venueLookup = createLookup(music.venues)
    async let bracket = await Bracket(music: music)
    async let relations = music.relationMap

    self.artistMap = await artistLookup
    self.venueMap = await venueLookup
    self.bracket = await bracket
    self.relationMap = await relations
  }

  var librarySortTokenMap: [String: String] {
    bracket.librarySortTokenMap
  }

  public var decadesMap: [Decade: [Annum: [Show.ID]]] {
    bracket.decadesMap
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
    bracket.artistRankingMap[artist.id] ?? Ranking.empty
  }

  public func venueRank(venue: Venue) -> Ranking {
    bracket.venueRankingMap[venue.id] ?? Ranking.empty
  }

  public func spanRank(artist: Artist) -> Ranking {
    bracket.artistShowSpanRankingMap[artist.id] ?? Ranking.empty
  }

  public func spanRank(venue: Venue) -> Ranking {
    bracket.venueShowSpanRankingMap[venue.id] ?? Ranking.empty
  }

  public func artistVenueRank(artist: Artist) -> Ranking {
    bracket.artistVenueRankingMap[artist.id] ?? Ranking.empty
  }

  public func venueArtistRank(venue: Venue) -> Ranking {
    bracket.venueArtistRankingMap[venue.id] ?? Ranking.empty
  }

  public func showRank(annum: Annum) -> Ranking {
    bracket.annumShowRankingMap[annum] ?? .empty
  }

  public func venueRank(annum: Annum) -> Ranking {
    bracket.annumVenueRankingMap[annum] ?? .empty
  }

  public func artistRank(annum: Annum) -> Ranking {
    bracket.annumArtistRankingMap[annum] ?? .empty
  }

  public func firstSet(artist: Artist) -> FirstSet {
    bracket.artistFirstSetsMap[artist.id] ?? FirstSet.empty
  }

  public func firstSet(venue: Venue) -> FirstSet {
    bracket.venueFirstSetsMap[venue.id] ?? FirstSet.empty
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
