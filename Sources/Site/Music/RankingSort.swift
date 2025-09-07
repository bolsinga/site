//
//  RankingSort.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import Foundation

enum RankingSort: Int, CaseIterable {
  case alphabetical
  case showCount
  case showYearRange
  case associatedRank
  case firstSeen

  var isAlphabetical: Bool {
    switch self {
    case .alphabetical:
      true
    default:
      false
    }
  }

  var isShowYearRange: Bool {
    switch self {
    case .showYearRange:
      true
    default:
      false
    }
  }

  var isFirstSeen: Bool {
    switch self {
    case .firstSeen:
      true
    default:
      false
    }
  }

  var localizedString: String {
    switch self {
    case .alphabetical:
      return String(localized: "Sort Alphabetically")
    case .showCount:
      return String(localized: "Sort By Show Count")
    case .showYearRange:
      return String(localized: "Sort By Year Range")
    case .associatedRank:
      return String(localized: "Sort By Associated")
    case .firstSeen:
      return String(localized: "Sort By First Show")
    }
  }
}
