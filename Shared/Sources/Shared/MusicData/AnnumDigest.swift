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
  private let rank: RankDigest

  public init(annum: Annum, shows: [ShowDigest], rank: RankDigest) {
    self.annum = annum
    self.shows = shows
    self.rank = rank
  }

  public var showRank: Ranking {
    rank.showRank
  }

  public var venueRank: Ranking {
    rank.spanRank
  }

  public var artistRank: Ranking {
    rank.associatedRank
  }
}
