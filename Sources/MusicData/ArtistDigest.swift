//
//  ArtistDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct ArtistDigest: Codable, Equatable, Hashable, Identifiable, Sendable {
  public var id: Artist.ID { artist.id }

  public let artist: Artist
  public let shows: [ShowDigest]
  public let related: [Related]
  public let rank: RankDigest

  public init(artist: Artist, shows: [ShowDigest], related: [Related], rank: RankDigest) {
    self.artist = artist
    self.shows = shows
    self.related = related
    self.rank = rank
  }
}
