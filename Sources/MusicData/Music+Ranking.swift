//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Music {
  func tracker<ID, AnnumID>(
    venueIdentifier: @Sendable (_ venue: String) -> ID,
    artistIdentifier: @Sendable (_ artist: String) -> ID,
    showIdentifier: @Sendable (_ artist: String) -> ID,
    annumIdentifier: @Sendable (_ annum: PartialDate) -> AnnumID
  ) -> Tracker<ID, AnnumID> {
    Tracker(
      shows: self.shows,
      venueIdentifier: venueIdentifier,
      artistIdentifier: artistIdentifier,
      showIdentifier: showIdentifier,
      annumIdentifier: annumIdentifier)
  }

  var relationMap: [String: [String]] {
    relations.reduce(into: [String: [String]]()) { d, relation in
      d = relation.members.reduce(into: d) { d, id in
        var arr = (d[id] ?? [])
        arr = Array(Set(arr).union(relation.members.filter { $0 != id }))
        d[id] = arr
      }
    }
  }
}
