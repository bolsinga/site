//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Music {
  var artistRankings: [Artist.ID: Ranking] {
    let artistShowCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = self.showsForArtist($1).count
    }.map { $0 }

    return computeRankings(items: artistShowCounts)
  }

  var venueRankings: [Venue.ID: Ranking] {
    let venuesShowCount: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) {
      $0[$1.id] = self.showsForVenue($1).count
    }.map { $0 }

    return computeRankings(items: venuesShowCount)
  }

  var artistSpanRankings: [Artist.ID: Ranking] {
    let artistShowSpans: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = self.showsForArtist($1).map { $0.date }.yearSpan
    }.map { $0 }

    return computeRankings(items: artistShowSpans)
  }

  var venueSpanRankings: [Venue.ID: Ranking] {
    let venueShowSpans: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) {
      $0[$1.id] = self.showsForVenue($1).map { $0.date }.yearSpan
    }.map { $0 }

    return computeRankings(items: venueShowSpans)
  }

  var artistVenueRankings: [Artist.ID: Ranking] {
    let artistVenueCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) {
      $0[$1.id] = Set(self.showsForArtist($1).map { $0.venue }).count
    }.map { $0 }

    return computeRankings(items: artistVenueCounts)
  }

  var venueArtistRankings: [Venue.ID: Ranking] {
    let venueArtistCounts: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) {
      $0[$1.id] = Set(self.showsForVenue($1).flatMap { $0.artists }).count
    }.map { $0 }

    return computeRankings(items: venueArtistCounts)
  }

  internal func computeRankings<T, V, R>(items: [(T, V)], rankBuilder: (Int, V) -> R) -> [T: R]
  where V: Hashable, V: Comparable {
    let itemRanks: [V: [T]] = Dictionary(grouping: items) { $0.1 }
      .reduce(into: [:]) {
        var arr = $0[$1.key] ?? []
        arr.append(contentsOf: $1.value.map { $0.0 })
        $0[$1.key] = arr
      }

    // ordered ascending
    let itemsOrdered: [([T], V)] = itemRanks.sorted(by: { $0.key < $1.key })
      .reduce(into: []) { $0.append(($1.value, $1.key)) }

    var rank = 1
    // T : Ordinal rank (1, 2, 3 etc)
    let itemRankMap: [T: R] = itemsOrdered.reversed().reduce(into: [:]) {
      dictionary, itemRankings in
      itemRankings.0.forEach { item in
        dictionary[item] = rankBuilder(rank, itemRankings.1)
      }
      rank += 1
    }
    return itemRankMap
  }

  internal func computeRankings<T>(items: [(T, Int)]) -> [T: Ranking] {
    computeRankings(items: items) {
      Ranking(rank: $0, value: $1)
    }
  }
}
