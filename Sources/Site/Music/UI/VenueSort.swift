//
//  VenueSort.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import Foundation

enum VenueSort: Int, Sorting {
  case alphabetical
  case showCount
  case showYearRange
  case venueArtistRank
  case firstSeen

  var localizedString: String {
    switch self {
    case .alphabetical:
      return String(localized: "Sort Alphabetically", bundle: .module)
    case .showCount:
      return String(localized: "Sort By Show Count", bundle: .module)
    case .showYearRange:
      return String(localized: "Sort By Year Range", bundle: .module)
    case .venueArtistRank:
      return String(localized: "Sort By Artist Count", bundle: .module)
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
