//
//  AnnumDigest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

public struct AnnumDigest: Codable, Sendable {
  public let annum: Annum
  public let shows: [ShowDigest]
  public let showRank: Ranking
  public let venueRank: Ranking
  public let artistRank: Ranking

  public init(
    annum: Annum, shows: [ShowDigest], showRank: Ranking, venueRank: Ranking,
    artistRank: Ranking
  ) {
    self.annum = annum
    self.shows = shows
    self.showRank = showRank
    self.venueRank = venueRank
    self.artistRank = artistRank
  }
}
