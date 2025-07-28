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
  @ViewBuilder func summary(
    nearbyModel: NearbyModel, statsDisplayArchiveCategoryCounts: Bool,
    venueSortSearch: () -> SortSearch, artistSortSearch: () -> SortSearch
  ) -> some View {
    switch self {
    case .today:
      TodaySummary()
    case .stats:
      StatsSummary(displayArchiveCategoryCounts: statsDisplayArchiveCategoryCounts)
    case .shows:
      ShowsSummary(nearbyModel: nearbyModel)
    case .venues:
      let sortSearch = venueSortSearch()
      VenuesSummary(
        nearbyModel: nearbyModel, sort: sortSearch.sort, searchString: sortSearch.search)
    case .artists:
      let sortSearch = artistSortSearch()
      ArtistsSummary(
        nearbyModel: nearbyModel, sort: sortSearch.sort, searchString: sortSearch.search)
    case .settings:
      SettingsView(nearbyModel: nearbyModel)
    }
  }
}
