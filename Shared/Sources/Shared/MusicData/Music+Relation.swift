//
//  Music+Relation.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Relation {
  fileprivate func relationMap() throws -> [ArchivePath: Set<ArchivePath>]
  {
    try members.reduce(into: [ArchivePath: Set<ArchivePath>]()) { d, id in
      let aid = try ArchivePath(raw: id)

      let mids: [ArchivePath] = try members.compactMap {
        let mid = try ArchivePath(raw: $0)
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
  func relationMap() throws -> [ArchivePath: Set<ArchivePath>]
  {
    try relations.reduce(into: [ArchivePath: Set<ArchivePath>]()) { d, relation in
      d.merge(try relation.relationMap()) { $0.union($1) }
    }
  }
}
