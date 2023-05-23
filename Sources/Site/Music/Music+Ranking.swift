//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Music {
  typealias ItemCount = ([String], Int)  // Int is the count. All the items in this array have the same count.
  typealias ItemRankings = [ItemCount]  // From least to most.
  typealias Rank = (rank: Int, count: Int)  // Ranking is 1...n and count
  typealias ItemRankingMap = [String: Rank]  // Lookup an items Rank

  var artistRankings: (ItemRankings, ItemRankingMap) {
    let artistShowCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = self.showsForArtist($1).count
    }.map { $0 }

    return computeRankings(items: artistShowCounts)
  }

  internal func computeRankings<T>(items: [(T, Int)]) -> ([([T], Int)], [T: Rank]) {
    let itemRanks: [Int: [T]] = Dictionary(grouping: items) { $0.1 }
      .reduce(into: [:]) {
        var arr = $0[$1.key] ?? []
        arr.append(contentsOf: $1.value.map { $0.0 })
        $0[$1.key] = arr
      }

    // ordered ascending
    let itemsOrdered: [([T], Int)] = itemRanks.sorted(by: { $0.key < $1.key })
      .reduce(into: []) { $0.append(($1.value, $1.key)) }

    var rank = 1
    // T : Ordinal Rank (1, 2, 3 etc)
    let itemRankMap: [T: Rank] = itemsOrdered.reversed().reduce(into: [:]) {
      dictionary, itemRankings in
      itemRankings.0.forEach { item in
        dictionary[item] = Rank(rank, itemRankings.1)
      }
      rank += 1
    }
    return (itemsOrdered, itemRankMap)
  }
}
