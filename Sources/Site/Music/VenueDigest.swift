//
//  VenueDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

public struct VenueDigest: Equatable, Hashable, Identifiable, Sendable {
  public var id: Venue.ID { venue.id }

  public let venue: Venue
  let url: URL?
  let concerts: [Concert]
  let related: [Venue]
  let firstSet: FirstSet
  let spanRank: Ranking
  let showRank: Ranking
  let venueArtistRank: Ranking
}

extension VenueDigest: LibraryComparable {
  public var sortname: String? {
    venue.sortname
  }

  public var name: String {
    venue.name
  }
}

extension Array where Element == VenueDigest {
  func ranked(by sort: RankingSort) -> [Ranking: [VenueDigest]] {
    self.reduce(into: [Ranking: [VenueDigest]]()) {
      let ranking = $1.ranking(for: sort)
      var arr = ($0[ranking] ?? [])
      arr.append($1)
      $0[ranking] = arr
    }
  }

  var firstSeen: [PartialDate: [VenueDigest]] {
    self.reduce(into: [PartialDate: [(VenueDigest, FirstSet)]]()) {
      let firstSet = $1.firstSet
      var arr = ($0[firstSet.date] ?? [])
      arr.append(($1, firstSet))
      $0[firstSet.date] = arr
    }.reduce(into: [PartialDate: [VenueDigest]]()) {
      $0[$1.key] = $1.value.sorted(by: { lhs, rhs in
        lhs.1.rank < rhs.1.rank
      }).map { $0.0 }
    }
  }
}
