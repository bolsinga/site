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

public struct Lookup<Identifier: ArchiveIdentifier>: Sendable {
  public typealias ID = Identifier.ID
  public typealias AnnumID = Identifier.AnnumID

  private let artistMap: [Artist.ID: Artist]
  private let venueMap: [Venue.ID: Venue]
  private let bracket: Bracket<Identifier>
  private let relationMap: [String: [String]]  // Artist/Venue ID : [Artist/Venue ID]

  public init(music: Music, identifier: Identifier) async {
    var signpost = Signpost(category: "lookup", name: "process")
    signpost.start()

    async let artistLookup = createLookup(music.artists)
    async let venueLookup = createLookup(music.venues)
    async let bracket = await Bracket(music: music, identifier: identifier)
    async let relations = music.relationMap

    self.artistMap = await artistLookup
    self.venueMap = await venueLookup
    self.bracket = await bracket
    self.relationMap = await relations
  }

  var librarySortTokenMap: [ID: String] {
    bracket.librarySortTokenMap
  }

  public var decadesMap: [Decade: [AnnumID: Set<ID>]] {
    bracket.decadesMap
  }

  public var concertDayMap: [Int: Set<ID>] {
    bracket.concertDayMap
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

  func rankDigest(annum: AnnumID) -> RankDigest {
    bracket.annumRankDigestMap[annum] ?? .empty
  }

  func rankDigest(artist: ID) -> RankDigest {
    bracket.artistRankDigestMap[artist] ?? .empty
  }

  func rankDigest(venue: ID) -> RankDigest {
    bracket.venueRankDigestMap[venue] ?? .empty
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
