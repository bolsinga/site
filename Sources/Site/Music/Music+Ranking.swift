//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Music {
  typealias ItemValue = ([String], Int)  // Int is the value. All the items in this array have the same value.
  typealias ItemRankings = [ItemValue]  // From least to most.
  typealias ItemRankingMap = [String: Ranking]  // Lookup an items Ranking

  var artistRankings: ItemRankingMap {
    let artistShowCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = self.showsForArtist($1).count
    }.map { $0 }

    return computeRankings(items: artistShowCounts)
  }

  var venueRankings: ItemRankingMap {
    let venuesShowCount: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) {
      $0[$1.id] = self.showsForVenue($1).count
    }.map { $0 }

    return computeRankings(items: venuesShowCount)
  }

  var artistSpanRankings: ItemRankingMap {
    let artistShowSpans: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = self.showsForArtist($1).map { $0.date }.yearSpan
    }.map { $0 }

    return computeRankings(items: artistShowSpans)
  }

  var venueSpanRankings: ItemRankingMap {
    let venueShowSpans: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) {
      $0[$1.id] = self.showsForVenue($1).map { $0.date }.yearSpan
    }.map { $0 }

    return computeRankings(items: venueShowSpans)
  }

  var artistVenueRankings: ItemRankingMap {
    let artistVenueCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = Set(self.showsForArtist($1).map { $0.venue }).count
    }.map { $0 }

    return computeRankings(items: artistVenueCounts)
  }

  internal func computeRankings<T>(items: [(T, Int)]) -> [T: Ranking] {
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
    // T : Ordinal rank (1, 2, 3 etc)
    let itemRankMap: [T: Ranking] = itemsOrdered.reversed().reduce(into: [:]) {
      dictionary, itemRankings in
      itemRankings.0.forEach { item in
        dictionary[item] = Ranking(rank: rank, count: itemRankings.1)
      }
      rank += 1
    }
    return itemRankMap
  }
}
