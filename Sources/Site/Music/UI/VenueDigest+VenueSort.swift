//
//  VenueDigest+VenueSort.swift
//
//
//  Created by Greg Bolsinga on 6/2/24.
//

import Foundation

extension VenueDigest {
  func ranking(for sort: VenueSort) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      return Ranking.empty
    case .showCount:
      return self.showRank
    case .showYearRange:
      return self.spanRank
    case .venueArtistRank:
      return self.venueArtistRank
    }
  }
}
