//
//  ArtistSort.swift
//
//
//  Created by Greg Bolsinga on 6/3/23.
//

import Foundation

enum ArtistSort: Int, Sorting {
  case alphabetical
  case showCount
  case showYearRange
  case venueRank
  case firstSeen

  var localizedString: String {
    switch self {
    case .alphabetical:
      return String(localized: "Sort Alphabetically", bundle: .module)
    case .showCount:
      return String(localized: "Sort By Show Count", bundle: .module)
    case .showYearRange:
      return String(localized: "Sort By Year Range", bundle: .module)
    case .venueRank:
      return String(localized: "Sort By Venue Count", bundle: .module)
    case .firstSeen:
      return String(localized: "Sort By First Show", bundle: .module)
    }
  }

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
}
