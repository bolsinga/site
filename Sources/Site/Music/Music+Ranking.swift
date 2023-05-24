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

  var artistRankings: (ItemRankings, ItemRankingMap) {
    let artistShowCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = self.showsForArtist($1).count
    }.map { $0 }

    return computeRankings(items: artistShowCounts)
  }

  var venueRankings: (ItemRankings, ItemRankingMap) {
    let venuesShowCount: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) {
      $0[$1.id] = self.showsForVenue($1).count
    }.map { $0 }

    return computeRankings(items: venuesShowCount)
  }

  private func computedYears(shows: [Show]) -> [PartialDate] {
    return Array(
      Set(shows.map { $0.date.year != nil ? PartialDate(year: $0.date.year!) : PartialDate() })
    ).sorted(by: <)
  }

  var artistSpanRankings: (ItemRankings, ItemRankingMap) {
    let artistShowSpans: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = computedYears(shows: self.showsForArtist($1)).yearSpan()
    }.map { $0 }

    return computeRankings(items: artistShowSpans)
  }

  var venueSpanRankings: (ItemRankings, ItemRankingMap) {
    let venueShowSpans: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) {
      $0[$1.id] = computedYears(shows: self.showsForVenue($1)).yearSpan()
    }.map { $0 }

    return computeRankings(items: venueShowSpans)
  }

  internal func computeRankings<T>(items: [(T, Int)]) -> ([([T], Int)], [T: Ranking]) {
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
    return (itemsOrdered, itemRankMap)
  }
}
