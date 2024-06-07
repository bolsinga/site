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
      Ranking.empty
    case .showCount:
      showRank
    case .showYearRange:
      spanRank
    case .associatedRank:
      venueArtistRank
    }
  }
}
