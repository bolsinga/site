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

  var localizedString: String {
    switch self {
    case .alphabetical:
      return String(
        localized: "Sort Alphabetically", bundle: .module,
        comment: "VenueSort.alphabetical")
    case .showCount:
      return String(
        localized: "Sort By Show Count", bundle: .module,
        comment: "VenueSort.showCount")
    case .showYearRange:
      return String(
        localized: "Sort By Year Range", bundle: .module,
        comment: "VenueSort.showYearRange")
    case .venueArtistRank:
      return String(
        localized: "Sort By Artist Count", bundle: .module,
        comment: "VenueSort.venueArtistRank")
    }
  }
}
