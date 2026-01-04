//
//  Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

public struct Ranking: Codable, Comparable, Hashable, Sendable {
  public let rank: Rank
  public let value: Int

  public init(rank: Rank, value: Int) {
    self.rank = rank
    self.value = value
  }

  public static var empty: Ranking {
    Ranking(rank: .unknown, value: 0)
  }

  public static func < (lhs: Ranking, rhs: Ranking) -> Bool {
    if lhs.rank == rhs.rank {
      return lhs.value < rhs.value
    }
    return lhs.rank < rhs.rank
  }
}
