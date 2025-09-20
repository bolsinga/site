//
//  AnnumDigest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

public struct AnnumDigest: Sendable {
  public let annum: Annum
  public let url: URL?
  public let concerts: [Concert]
  public let showRank: Ranking
  public let venueRank: Ranking
  public let artistRank: Ranking

  public init(
    annum: Annum, url: URL? = nil, concerts: [Concert], showRank: Ranking, venueRank: Ranking,
    artistRank: Ranking
  ) {
    self.annum = annum
    self.url = url
    self.concerts = concerts
    self.showRank = showRank
    self.venueRank = venueRank
    self.artistRank = artistRank
  }
}
