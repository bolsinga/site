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
  /// The number of artists whose most recent show was in this annum.
  public let mostRecentArtistCount: Int
  /// The number of venues whose most recent show was in this annum.
  public let mostRecentVenueCount: Int

  public init(
    annum: Annum, shows: [ShowDigest], rank: RankDigest, newArtistCount: Int = 0,
    newVenueCount: Int = 0, mostRecentArtistCount: Int = 0, mostRecentVenueCount: Int = 0
  ) {
    self.annum = annum
    self.shows = shows
    self.rank = rank
    self.newArtistCount = newArtistCount
    self.newVenueCount = newVenueCount
    self.mostRecentArtistCount = mostRecentArtistCount
    self.mostRecentVenueCount = mostRecentVenueCount
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
