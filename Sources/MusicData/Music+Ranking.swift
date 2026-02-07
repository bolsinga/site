//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Relation {
  func relationMap<Identifier: ArchiveIdentifier>(identifier: Identifier) throws -> [Identifier.ID:
    Set<Identifier.ID>]
  {
    try members.reduce(into: [Identifier.ID: Set<Identifier.ID>]()) { d, id in
      let aid = try identifier.relation(id)

      let mids: [Identifier.ID] = try members.compactMap {
        let mid = try identifier.relation($0)
        guard mid != aid else { return nil }
        return mid
      }

      var arr = d[aid] ?? []
      arr = arr.union(mids)
      d[aid] = arr
    }
  }
}

extension Music {
  func tracker<Identifier: ArchiveIdentifier>(identifier: Identifier) throws -> Tracker<Identifier>
  {
    try Tracker(shows: self.shows, identifier: identifier)
  }

  func relationMap<Identifier: ArchiveIdentifier>(identifier: Identifier) throws
    -> [Identifier.ID: Set<Identifier.ID>]
  {
    try relations.reduce(into: [Identifier.ID: Set<Identifier.ID>]()) { d, relation in
      d.merge(try relation.relationMap(identifier: identifier)) { $0.union($1) }
    }
  }
}
