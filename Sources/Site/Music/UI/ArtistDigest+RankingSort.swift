//
//  ArtistDigest+RankingSort.swift
//
//
//  Created by Greg Bolsinga on 6/2/24.
//

import Foundation

extension ArtistDigest {
  func ranking(for sort: RankingSort) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      Ranking.empty
    case .showCount:
      rank.showRank
    case .showYearRange:
      rank.spanRank
    case .associatedRank:
      rank.associatedRank
    }
  }
}
