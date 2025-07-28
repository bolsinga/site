//
//  ArchiveCategoryRoot.swift
//  site
//
//  Created by Greg Bolsinga on 10/14/24.
//

import SwiftUI

struct ArchiveCategoryRoot: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel

  let category: ArchiveCategory
  let statsDisplayArchiveCategoryCounts: Bool
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  @State private var artistSearchString: String = ""
  @State private var venueSearchString: String = ""

  private func sortableData(_ category: ArchiveCategory) -> (
    sort: Binding<RankingSort>, associatedRankName: String
  )? {
    switch category {
    case .today, .stats, .shows, .settings:
      nil
    case .venues:
      ($venueSort, String(localized: "Sort By Artist Count", bundle: .module))
    case .artists:
      ($artistSort, String(localized: "Sort By Venue Count", bundle: .module))
    }
  }

  var body: some View {
    category.summary(
      statsDisplayArchiveCategoryCounts: statsDisplayArchiveCategoryCounts,
      venueSortSearch: { (venueSort, $venueSearchString) },
      artistSortSearch: { (artistSort, $artistSearchString) }
    )
    .toolbar {
      if category.isLocationFilterable {
        @Bindable var bindableNearbyModel = nearbyModel
        LocationFilterToolbarContent(isOn: $bindableNearbyModel.locationFilter.toggle)
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
}

// Preview only extension
extension ArchiveCategoryRoot {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      category: category, statsDisplayArchiveCategoryCounts: false,
      venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical))
  }
}

#Preview {
  ArchiveCategoryRoot(withPreviewCategory: .today)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}

#Preview {
  ArchiveCategoryRoot(withPreviewCategory: .stats)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}

#Preview {
  ArchiveCategoryRoot(withPreviewCategory: .shows)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}

#Preview {
  ArchiveCategoryRoot(withPreviewCategory: .venues)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}

#Preview {
  ArchiveCategoryRoot(withPreviewCategory: .artists)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}
