//
//  LibrarySectionAlgorithm.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import Foundation

enum LibrarySectionAlgorithm: Int, CaseIterable {
  case alphabetical
  case showCount
  case showYearRange

  var localizedString: String {
    switch self {
    case .alphabetical:
      return String(
        localized: "Alphabetical", bundle: .module, comment: "LibrarySectionAlgorithm.alphabetical")
    case .showCount:
      return String(
        localized: "Show Count", bundle: .module, comment: "LibrarySectionAlgorithm.showCount")
    case .showYearRange:
      return String(
        localized: "Show Year Range", bundle: .module,
        comment: "LibrarySectionAlgorithm.showYearRange")
    }
  }
}
