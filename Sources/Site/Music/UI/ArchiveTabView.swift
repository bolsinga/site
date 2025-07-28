//
//  ArchiveTabView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

extension ArchiveCategory {
  fileprivate func badge(_ model: VaultModel) -> Text? {
    let count = model.todayConcerts.count
    guard count > 0 else { return nil }
    switch self {
    case .today:
      return Text(String(count))
    case .stats, .shows, .venues, .artists, .settings:
      return nil
    }
  }

  fileprivate static var tagOrder: [ArchiveCategory] {
    allCases.filter {
      if case .stats = $0 { return false }
      if case .settings = $0 { return false }
      return true
    } + [.stats, .settings]
  }
}

struct ArchiveTabView: View {
  @Environment(VaultModel.self) var model

  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  @Binding var selectedCategory: ArchiveCategory
  let pathForCategory: (ArchiveCategory) -> Binding<[ArchivePath]>
  let nearbyModel: NearbyModel

  var body: some View {
    TabView(selection: $selectedCategory) {
      ForEach(ArchiveCategory.tagOrder, id: \.self) { category in
        Tab(category.localizedString, systemImage: category.systemImage, value: category) {
          ArchiveCategoryStack(
            category: category, statsDisplayArchiveCategoryCounts: false,
            path: pathForCategory(category), venueSort: $venueSort, artistSort: $artistSort,
            nearbyModel: nearbyModel)
        }
        #if !os(tvOS)
          .badge(category.badge(model))
        #endif
      }
    }
    .tabViewStyle(.sidebarAdaptable)
  }
}

#Preview {
  ArchiveTabView(
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    selectedCategory: .constant(.today), pathForCategory: { _ in .constant([]) },
    nearbyModel: NearbyModel()
  )
  .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
