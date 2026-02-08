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

public struct Lookup<Identifier: ArchiveIdentifier>: Codable, Sendable {
  public typealias ID = Identifier.ID
  public typealias AnnumID = Identifier.AnnumID

  private let identifier: Identifier
  private let artistMap: [ID: Artist]
  private let venueMap: [ID: Venue]
  private let bracket: Bracket<Identifier>
  private let relationMap: [ID: Set<ID>]  // Artist/Venue ID : Set<Artist/Venue ID>

  public init(music: Music, identifier: Identifier) async throws {
    var signpost = Signpost(category: "lookup", name: "process")
    signpost.start()

    async let artistLookup = music.artists.reduce(into: [:]) {
      $0[try identifier.artist($1.id)] = $1
    }
    async let venueLookup = music.venues.reduce(into: [:]) { $0[try identifier.venue($1.id)] = $1 }
    async let bracket = await Bracket(music: music, identifier: identifier)
    async let relations = music.relationMap(identifier: identifier)

    self.identifier = identifier
    self.artistMap = try await artistLookup
    self.venueMap = try await venueLookup
    self.bracket = try await bracket
    self.relationMap = try await relations
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
    guard let id = try? identifier.venue(show.venue), let venue = venueMap[id] else {
      Logger.lookup.log("Show: \(show.id, privacy: .public) missing venue")
      return nil
    }
    return venue
  }

  public func artistsForShow(_ show: Show) -> [Artist] {
    var showArtists = [Artist]()
    for id in show.artists {
      guard let aid = try? identifier.artist(id), let artist = artistMap[aid] else {
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

  public func related(_ item: Venue) -> any Collection<Related> {
    guard let id = try? identifier.relation(item.id) else { return [] }
    return relationMap[id]?.compactMap { venueMap[$0] }.map {
      Related(id: $0.archivePath, name: $0.name)
    } ?? []
  }

  public func related(_ item: Artist) -> any Collection<Related> {
    guard let id = try? identifier.relation(item.id) else { return [] }
    return relationMap[id]?.compactMap { artistMap[$0] }.map {
      Related(id: $0.archivePath, name: $0.name)
    } ?? []
  }
}
