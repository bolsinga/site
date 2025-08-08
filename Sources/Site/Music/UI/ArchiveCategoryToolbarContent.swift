//
//  ArchiveCategoryToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 8/6/25.
//

import SwiftUI

struct ArchiveCategoryToolbarContent: ToolbarContent {
  @Environment(VaultModel.self) var model

  let category: ArchiveCategory

  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  @Binding private var showNearbyDistanceSettings: Bool

  internal init(
    category: ArchiveCategory, venueSort: Binding<RankingSort>, artistSort: Binding<RankingSort>,
    showNearbyDistanceSettings: Binding<Bool>
  ) {
    self.category = category
    self._venueSort = venueSort
    self._artistSort = artistSort
    self._showNearbyDistanceSettings = showNearbyDistanceSettings
  }

  private func sortableData(_ category: ArchiveCategory) -> (
    sort: Binding<RankingSort>, associatedRankName: String
  )? {
    switch category {
    case .today, .stats, .shows, .settings, .search:
      nil
    case .venues:
      ($venueSort, String(localized: "Sort By Artist Count", bundle: .module))
    case .artists:
      ($artistSort, String(localized: "Sort By Venue Count", bundle: .module))
    }
  }

  var body: some ToolbarContent {
    if category.isLocationFilterable {
      LocationFilterToolbarContent { showNearbyDistanceSettings = true }
    }
    if let sortableData = sortableData(category) {
      SortModifierToolbarContent(algorithm: sortableData.sort) {
        switch $0 {
        case .associatedRank:
          return sortableData.associatedRankName
        default:
          return $0.localizedString
        }
      }
    }
    ArchiveSharableToolbarContent(
      item: ArchiveCategoryLinkable(vault: model.vault, category: category))
  }
}
