//
//  ArchivePath+EntityIdentifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/25/26.
//

import AppIntents
import Shared

extension ArchivePath: @retroactive EntityIdentifierConvertible {
  public var entityIdentifierString: String {
    formatted(.rawID)
  }

  public static func entityIdentifier(for entityIdentifierString: String) -> ArchivePath? {
    try? ArchivePath(raw: entityIdentifierString)
  }
}
