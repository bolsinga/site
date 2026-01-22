//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Music {
  var tracker: Tracker {
    Tracker(shows: self.shows)
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
