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
  case artistVenueRank
  case venueArtistRank

  var localizedString: String {
    switch self {
    case .alphabetical:
      return String(
        localized: "Sort Alphabetically", bundle: .module,
        comment: "LibrarySectionAlgorithm.alphabetical")
    case .showCount:
      return String(
        localized: "Sort By Show Count", bundle: .module,
        comment: "LibrarySectionAlgorithm.showCount")
    case .showYearRange:
      return String(
        localized: "Sort By Year Range", bundle: .module,
        comment: "LibrarySectionAlgorithm.showYearRange")
    case .artistVenueRank:
      return String(
        localized: "Sort By Venue Count", bundle: .module,
        comment: "LibrarySectionAlgorithm.artistVenueRank")
    case .venueArtistRank:
      return String(
        localized: "Sort By Artist Count", bundle: .module,
        comment: "LibrarySectionAlgorithm.venueArtistRank")
    }
  }
}

extension LibrarySectionAlgorithm: Sorting {}
