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
      String(localized: "All", bundle: .module, comment: "ArchiveScope.all")
    case .artist:
      String(localized: "Artist", bundle: .module, comment: "ArchiveScope.artist")
    case .venue:
      String(localized: "Venue", bundle: .module, comment: "ArchiveScope.venue")
    }
  }
}
