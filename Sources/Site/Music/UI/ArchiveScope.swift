//
//  ArchiveScope.swift
//  site
//
//  Created by Greg Bolsinga on 8/17/25.
//

import Foundation

enum ArchiveScope: CaseIterable {
  case all
  case artist
  case venue

  var localizedString: String {
    switch self {
    case .all:
      String(localized: "All", comment: "ArchiveScope.all")
    case .artist:
      String(localized: "Artist", comment: "ArchiveScope.artist")
    case .venue:
      String(localized: "Venue", comment: "ArchiveScope.venue")
    }
  }
}
