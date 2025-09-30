//
//  TopDate.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/26/25.
//

import Foundation

extension Array where Element == (Date, Int) {
  fileprivate func matching(rank: Rank) -> [Date] {
    computeRankings(items: self).filter { $0.value.rank == rank }.map { $0.key }
  }
}

extension Array where Element == (Int, (Date, Int)) {
  var topDate: Date? {
    let tops = map { $0.1 }.matching(rank: .rank(1))
    return tops.count == 1 ? tops.first : nil
  }
}
