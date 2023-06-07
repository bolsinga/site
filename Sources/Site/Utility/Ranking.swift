//
//  Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

struct Ranking: Comparable, Hashable {
  let rank: Int  // 1...n
  let value: Int

  static var empty: Ranking {
    Ranking(rank: 0, value: 0)
  }

  static func < (lhs: Ranking, rhs: Ranking) -> Bool {
    if lhs.rank == rhs.rank {
      return lhs.value < rhs.value
    }
    return lhs.rank < rhs.rank
  }
}
