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
  /// The number of artists whose first show was in this annum.
  public let newArtistCount: Int
  /// The number of venues whose first show was in this annum.
  public let newVenueCount: Int

  public init(
    annum: Annum, shows: [ShowDigest], rank: RankDigest, newArtistCount: Int = 0,
    newVenueCount: Int = 0
  ) {
    self.annum = annum
    self.shows = shows
    self.rank = rank
    self.newArtistCount = newArtistCount
    self.newVenueCount = newVenueCount
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
