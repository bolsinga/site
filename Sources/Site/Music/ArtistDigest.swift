//
//  ArtistDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct ArtistDigest: Equatable, Hashable, Identifiable, Sendable {
  public var id: Artist.ID { artist.id }

  public let artist: Artist
  let url: URL?
  public let concerts: [Concert]
  let related: [Artist]
  let firstSet: FirstSet
  let spanRank: Ranking
  let showRank: Ranking
  let venueRank: Ranking
}

extension ArtistDigest: LibraryComparable {
  public var sortname: String? {
    artist.sortname
  }

  public var name: String {
    artist.name
  }
}

extension Array where Element == ArtistDigest {
  func ranked(by sort: RankingSort) -> [Ranking: [ArtistDigest]] {
    self.reduce(into: [Ranking: [ArtistDigest]]()) {
      let ranking = $1.ranking(for: sort)
      var arr = ($0[ranking] ?? [])
      arr.append($1)
      $0[ranking] = arr
    }
  }

  var firstSeen: [PartialDate: [ArtistDigest]] {
    self.reduce(into: [PartialDate: [(ArtistDigest, FirstSet)]]()) {
      let firstSet = $1.firstSet
      var arr = ($0[firstSet.date] ?? [])
      arr.append(($1, firstSet))
      $0[firstSet.date] = arr
    }.reduce(into: [PartialDate: [ArtistDigest]]()) {
      $0[$1.key] = $1.value.sorted(by: { lhs, rhs in
        lhs.1.rank < rhs.1.rank
      }).map { $0.0 }
    }
  }
}
