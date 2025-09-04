//
//  ArtistDigest+RankingSort.swift
//
//
//  Created by Greg Bolsinga on 6/2/24.
//

import Foundation
import MusicData

extension ArtistDigest {
  func ranking(for sort: RankingSort) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      Ranking.empty
    case .showCount:
      showRank
    case .showYearRange:
      spanRank
    case .associatedRank:
      venueRank
    }
  }
}
