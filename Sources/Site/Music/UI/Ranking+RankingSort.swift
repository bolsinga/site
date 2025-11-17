//
//  Ranking+RankingSort.swift
//
//
//  Created by Greg Bolsinga on 6/7/24.
//

import SwiftUI

extension Ranking {
  @ViewBuilder func sectionHeader(for sort: RankingSort) -> some View {
    switch sort {
    case .alphabetical, .firstSeen, .associatedRank:
      EmptyView()
    case .showCount:
      showsCountView
    case .showYearRange:
      yearsCountView
    }
  }
}
