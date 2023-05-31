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
        localized: "Sort Alphabetically", bundle: .module, comment: "LibrarySectionAlgorithm.alphabetical")
    case .showCount:
      return String(
        localized: "Sort By Show Count", bundle: .module, comment: "LibrarySectionAlgorithm.showCount")
    case .showYearRange:
      return String(
        localized: "Sort By Year Range", bundle: .module,
        comment: "LibrarySectionAlgorithm.showYearRange")
    }
  }
}
