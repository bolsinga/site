//
//  LibrarySectionAlgorithm+LibrarySection.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import SwiftUI

extension LibrarySectionAlgorithm {
  @ViewBuilder func itemContentView(_ count: Int) -> some View {
    switch self {
    case .alphabetical, .showYearRange:
      Text("\(count) Show(s)", bundle: .module, comment: "Value for the Artist # of Shows.")
    case .showCount, .artistVenueRank, .venueArtistRank:
      EmptyView()
    }
  }

  @ViewBuilder func headerView(_ section: LibrarySection) -> some View {
    switch self {
    case .alphabetical:
      section.representingView
    case .showCount:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.showsCountView
      }
    case .showYearRange:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.yearsCountView
      }
    case .artistVenueRank:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.venuesCountView
      }
    case .venueArtistRank:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.artistsCountView
      }
    }
  }
}
