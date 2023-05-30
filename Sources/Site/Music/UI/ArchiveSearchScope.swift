//
//  ArchiveSearchScope.swift
//
//
//  Created by Greg Bolsinga on 5/30/23.
//

import Foundation

enum ArchiveSearchScope: CaseIterable {
  case artist
  case venue

  var localizedString: String {
    switch self {
    case .artist:
      return String(localized: "Artist", bundle: .module, comment: "ArchiveSearchScope.artist")
    case .venue:
      return String(localized: "Venue", bundle: .module, comment: "ArchiveSearchScope.venue")
    }
  }
}
