//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Music {
  typealias ArtistsShowCount = ([Artist], Int)  // Int is the showCount. All the Artists in this array have the same show count.
  typealias ArtistRankings = [ArtistsShowCount]  // From least to most.
  typealias Rank = (Int, Int)  // Ranking is 1...n and showCount
  typealias ArtistRankingMap = [Artist: Rank]  // Lookup an Artists Rank

  var artistRankings: (ArtistRankings, ArtistRankingMap) {
    // NOTE: This one here can become [(ID, Int)] and then the rest will work for venues and other counts (such as year spans?)
    let artistShowCounts: [(Artist, Int)] = self.artists.reduce(into: [:]) {
      $0[$1] = self.showsForArtist($1).count
    }.map { $0 }

    // ShowCount: [Artist]
    let artistRanks: [Int: [Artist]] = Dictionary(grouping: artistShowCounts) { $0.1 }
      .reduce(into: [:]) {
        var arr = $0[$1.key] ?? []
        arr.append(contentsOf: $1.value.map { $0.0 })
        $0[$1.key] = arr
      }

    // least shows to most shows
    let artistsOrderedByShowCount: ArtistRankings = artistRanks.sorted(by: { $0.key < $1.key })
      .reduce(into: []) { $0.append(ArtistsShowCount($1.value, $1.key)) }

    var rank = 1
    // Artist : Ordinal Rank (1, 2, 3 etc)
    let artistRankMap: ArtistRankingMap = artistsOrderedByShowCount.reversed().reduce(into: [:]) {
      dictionary, artistRankings in
      artistRankings.0.forEach { artist in
        dictionary[artist] = (rank, artistRankings.1)
      }
      rank += 1
    }

    return (artistsOrderedByShowCount, artistRankMap)
  }
}
