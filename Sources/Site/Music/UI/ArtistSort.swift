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

  var localizedString: String {
    switch self {
    case .alphabetical:
      return String(
        localized: "Sort Alphabetically", bundle: .module,
        comment: "ArtistSort.alphabetical")
    case .showCount:
      return String(
        localized: "Sort By Show Count", bundle: .module,
        comment: "ArtistSort.showCount")
    case .showYearRange:
      return String(
        localized: "Sort By Year Range", bundle: .module,
        comment: "ArtistSort.showYearRange")
    case .venueRank:
      return String(
        localized: "Sort By Venue Count", bundle: .module,
        comment: "ArtistSort.artistVenueRank")
    }
  }
}
