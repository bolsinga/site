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
  public let firstSet: FirstSet
  public let spanRank: Ranking
  public let showRank: Ranking
  public let venueRank: Ranking

  public init(
    artist: Artist, shows: [ShowDigest], related: [Related], firstSet: FirstSet,
    spanRank: Ranking, showRank: Ranking, venueRank: Ranking
  ) {
    self.artist = artist
    self.shows = shows
    self.related = related
    self.firstSet = firstSet
    self.spanRank = spanRank
    self.showRank = showRank
    self.venueRank = venueRank
  }
}
