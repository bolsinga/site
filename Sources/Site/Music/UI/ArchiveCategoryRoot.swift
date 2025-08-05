//
//  ArchiveCategoryRoot.swift
//  site
//
//  Created by Greg Bolsinga on 10/14/24.
//

import SwiftUI

struct ArchiveCategoryRoot: View {
  @Environment(VaultModel.self) var model

  let category: ArchiveCategory
  let statsDisplayArchiveCategoryCounts: Bool
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  let reloadModel: @MainActor () async -> Void

  @State private var artistSearchString: String = ""
  @State private var venueSearchString: String = ""

  @State private var showNearbyDistanceSettings: Bool = false

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
    .refreshable { await reloadModel() }
    .toolbar {
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
    .sheet(isPresented: $showNearbyDistanceSettings) { SettingsView() }
  }
}

// Preview only extension
extension ArchiveCategoryRoot {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      category: category, statsDisplayArchiveCategoryCounts: false,
      venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical), reloadModel: {})
  }
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .today)
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .stats)
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .shows)
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .venues)
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .artists)
}
