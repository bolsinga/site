//
//  RankDigest.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/1/26.
//

import Foundation

public struct RankDigest: Codable, Equatable, Hashable, Sendable {
  public let firstSet: FirstSet
  public let spanRank: Ranking
  public let showRank: Ranking
  public let associatedRank: Ranking

  public static var empty: RankDigest {
    .init(firstSet: .empty, spanRank: .empty, showRank: .empty, associatedRank: .empty)
  }
}
