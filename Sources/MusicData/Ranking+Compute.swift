//
//  Ranking+Compute.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/29/25.
//

import Foundation

private func computeRankings<T, V, R>(
  items: [(T, V)], rankBuilder: (Rank, V) -> R, rankSorted: (V, V) -> Bool
) -> [T: R]
where V: Hashable, V: Comparable {
  let itemRanks: [V: [T]] = Dictionary(grouping: items) { $0.1 }
    .reduce(into: [:]) {
      var arr = $0[$1.key] ?? []
      arr.append(contentsOf: $1.value.map { $0.0 })
      $0[$1.key] = arr
    }

  let itemsOrdered: [([T], V)] = itemRanks.sorted(by: { rankSorted($0.key, $1.key) })
    .reduce(into: []) { $0.append(($1.value, $1.key)) }

  var rank = 1
  // T : Ordinal rank (1, 2, 3 etc)
  let itemRankMap: [T: R] = itemsOrdered.reduce(into: [:]) {
    dictionary, itemRankings in
    itemRankings.0.forEach { item in
      dictionary[item] = rankBuilder(.rank(rank), itemRankings.1)
    }
    rank += 1
  }
  return itemRankMap
}

func computeRankings<T>(items: [(T, Int)]) -> [T: Ranking] {
  computeRankings(items: items) {
    Ranking(rank: $0, value: $1)
  } rankSorted: {
    $0 > $1
  }
}
