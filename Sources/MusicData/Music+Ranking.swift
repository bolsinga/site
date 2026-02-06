//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Music {
  func tracker<Identifier: ArchiveIdentifier>(identifier: Identifier) throws -> Tracker<Identifier>
  {
    try Tracker(shows: self.shows, identifier: identifier)
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
