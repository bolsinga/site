//
//  Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

struct Ranking {
  let rank: Int  // 1...n
  let count: Int

  static var empty: Ranking {
    Ranking(rank: 0, count: 0)
  }
}
