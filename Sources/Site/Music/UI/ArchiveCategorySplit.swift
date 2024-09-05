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

  @Bindable var archiveNavigation: ArchiveNavigation
  let nearbyModel: NearbyModel

  private var vault: Vault { model.vault }

  @MainActor
  @ViewBuilder var sidebar: some View {
    List(
      ArchiveCategory.allCases, id: \.self,
      selection: $archiveNavigation.state.category
    ) {
      category in
      LabeledContent {
        switch category {
        case .today:
          Text(model.todayConcerts.count.formatted(.number))
            .animation(.easeInOut)
        case .stats:
          EmptyView()
        case .shows:
          Text(vault.concerts.count.formatted(.number))
        case .venues:
          Text(vault.venueDigests.count.formatted(.number))
        case .artists:
          Text(vault.artistDigests.count.formatted(.number))
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
        .nearbyDistanceThreshold(nearbyModel)
    } detail: {
      NavigationStack(path: $archiveNavigation.state.path) {
        ArchiveCategoryDetail(
          model: model, archiveNavigation: archiveNavigation, venueSort: $venueSort,
          artistSort: $artistSort, nearbyModel: nearbyModel)
      }
    }
  }
}
