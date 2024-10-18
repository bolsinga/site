//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import CoreLocation
import SwiftUI

struct ArchiveCategorySplit: View {
  let model: VaultModel

  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  @Binding var selectedCategory: ArchiveCategory?
  @Binding var path: [ArchivePath]
  let nearbyModel: NearbyModel

  @MainActor
  @ViewBuilder private var sidebar: some View {
    List(ArchiveCategory.allCases, id: \.self, selection: $selectedCategory) {
      category in
      LabeledContent {
        switch category {
        case .today:
          Text(model.todayConcerts.count.formatted(.number))
            .animation(.easeInOut)
        case .stats:
          EmptyView()
        case .shows:
          Text(model.vault.concerts.count.formatted(.number))
        case .venues:
          Text(model.vault.venueDigests.count.formatted(.number))
        case .artists:
          Text(model.vault.artistDigests.count.formatted(.number))
        case .settings:
          EmptyView()
        }
      } label: {
        category.label
      }
    }
  }

  var body: some View {
    NavigationSplitView {
      sidebar
        .navigationTitle(
          Text("Archives", bundle: .module)
        )
    } detail: {
      ArchiveCategoryDetail(
        model: model, category: selectedCategory, path: $path, venueSort: $venueSort,
        artistSort: $artistSort, nearbyModel: nearbyModel)
    }
  }
}
