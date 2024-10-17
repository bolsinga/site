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
    model: VaultModel, nearbyModel: NearbyModel, statsDisplayArchiveCategoryCounts: Bool,
    venueSortSearch: () -> SortSearch, artistSortSearch: () -> SortSearch
  ) -> some View {
    switch self {
    case .today:
      TodaySummary(model: model)
    case .stats:
      StatsSummary(
        vault: model.vault, displayArchiveCategoryCounts: statsDisplayArchiveCategoryCounts)
    case .shows:
      ShowsSummary(model: model, nearbyModel: nearbyModel)
    case .venues:
      let sortSearch = venueSortSearch()
      VenuesSummary(
        model: model, nearbyModel: nearbyModel, sort: sortSearch.sort,
        searchString: sortSearch.search)
    case .artists:
      let sortSearch = artistSortSearch()
      ArtistsSummary(
        model: model, nearbyModel: nearbyModel, sort: sortSearch.sort,
        searchString: sortSearch.search)
    }
  }
}
