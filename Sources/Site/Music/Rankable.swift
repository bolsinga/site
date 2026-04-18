//
//  Rankable.swift
//
//
//  Created by Greg Bolsinga on 6/8/24.
//

import Foundation

protocol Rankable: Hashable, PathRestorable {
  var firstSet: FirstSet { get }
  var showRank: Ranking { get }
  var section: LibrarySection? { get }
  func ranking(for sort: RankingSort) -> Ranking
}

extension Array where Element: Rankable {
  func ranked(by sort: RankingSort) -> [Ranking: [Element]] {
    self.reduce(into: [Ranking: [Element]]()) {
      let ranking = $1.ranking(for: sort)
      var arr = ($0[ranking] ?? [])
      arr.append($1)
      $0[ranking] = arr
    }
  }

  var firstSeen: [PartialDate: [Element]] {
    self.reduce(into: [PartialDate: [(Element, FirstSet)]]()) {
      let firstSet = $1.firstSet
      var arr = ($0[firstSet.date] ?? [])
      arr.append(($1, firstSet))
      $0[firstSet.date] = arr
    }.reduce(into: [PartialDate: [Element]]()) {
      $0[$1.key] = $1.value.sorted(by: { lhs, rhs in
        lhs.1.rank < rhs.1.rank
      }).map { $0.0 }
    }
  }

  var sections: [LibrarySection: [Element]] {
    self.reduce(into: [:]) {
      guard let section = $1.section else { return }
      var arr = $0[section] ?? []
      arr.append($1)
      $0[section] = arr
    }
  }
}
