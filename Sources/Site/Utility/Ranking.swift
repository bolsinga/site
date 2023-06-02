//
//  Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

struct Ranking: Hashable {
  let rank: Int  // 1...n
  let value: Int

  static var empty: Ranking {
    Ranking(rank: 0, value: 0)
  }
}
