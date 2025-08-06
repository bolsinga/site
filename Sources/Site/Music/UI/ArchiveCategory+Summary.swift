//
//  ArchiveCategory+Summary.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import SwiftUI

extension ArchiveCategory {
  typealias SortSearch = (sort: RankingSort, search: Binding<String>)

  @MainActor
  @ViewBuilder func summary(venueSortSearch: () -> SortSearch, artistSortSearch: () -> SortSearch)
    -> some View
  {
    switch self {
    case .today:
      TodaySummary()
    case .stats:
      StatsSummary()
    case .shows:
      ShowsSummary()
    case .venues:
      let sortSearch = venueSortSearch()
      VenuesSummary(sort: sortSearch.sort, searchString: sortSearch.search)
    case .artists:
      let sortSearch = artistSortSearch()
      ArtistsSummary(sort: sortSearch.sort, searchString: sortSearch.search)
    case .settings:
      SettingsView()
    }
  }
}
