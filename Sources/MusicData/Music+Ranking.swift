//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Relation {
  var relationMap: [String: Set<String>] {
    members.reduce(into: [String: Set<String>]()) { d, id in
      var arr = d[id] ?? []
      arr = arr.union(members.filter { $0 != id })
      d[id] = arr
    }
  }
}

extension Music {
  func tracker<Identifier: ArchiveIdentifier>(identifier: Identifier) throws -> Tracker<Identifier>
  {
    try Tracker(shows: self.shows, identifier: identifier)
  }

  var relationMap: [String: Set<String>] {
    relations.reduce(into: [String: Set<String>]()) { d, relation in
      d.merge(relation.relationMap) { $0.union($1) }
    }
  }
}
