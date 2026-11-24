//
//  EntityPath.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/25/26.
//

import AppIntents
import SiteCore

/// The identifier of an entity: the path of its archive item, as the system saves it.
struct EntityPath: EntityIdentifierConvertible, Hashable, Sendable {
  let path: ArchivePath

  init(_ path: ArchivePath) {
    self.path = path
  }

  var entityIdentifierString: String {
    path.formatted(.rawID)
  }

  static func entityIdentifier(for entityIdentifierString: String) -> EntityPath? {
    (try? ArchivePath(raw: entityIdentifierString)).map(EntityPath.init)
  }
}
