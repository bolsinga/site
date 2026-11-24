//
//  Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

package struct Ranking: Codable, Comparable, Hashable, Sendable {
  package let rank: Rank
  package let value: Int

  public init(rank: Rank, value: Int) {
    self.rank = rank
    self.value = value
  }

  package static var empty: Ranking {
    Ranking(rank: .unknown, value: 0)
  }

  package static func < (lhs: Ranking, rhs: Ranking) -> Bool {
    if lhs.rank == rhs.rank {
      return lhs.value < rhs.value
    }
    return lhs.rank < rhs.rank
  }
}
