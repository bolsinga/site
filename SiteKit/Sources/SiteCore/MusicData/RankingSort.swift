//
//  RankingSort.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import Foundation

package enum RankingSort: Int, CaseIterable, Sendable {
  case alphabetical
  case showCount
  case showYearRange
  case associatedRank
  case firstSeen

  package var isAlphabetical: Bool {
    switch self {
    case .alphabetical:
      true
    default:
      false
    }
  }

  package var isShowYearRange: Bool {
    switch self {
    case .showYearRange:
      true
    default:
      false
    }
  }

  package var isFirstSeen: Bool {
    switch self {
    case .firstSeen:
      true
    default:
      false
    }
  }

  package var localizedString: String {
    switch self {
    case .alphabetical:
      return String(localized: "Sort Alphabetically", bundle: #bundle)
    case .showCount:
      return String(localized: "Sort By Show Count", bundle: #bundle)
    case .showYearRange:
      return String(localized: "Sort By Year Range", bundle: #bundle)
    case .associatedRank:
      return String(localized: "Sort By Associated", bundle: #bundle)
    case .firstSeen:
      return String(localized: "Sort By First Show", bundle: #bundle)
    }
  }
}
