//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

struct ArchiveStateView: View {
  let model: VaultModel

  @SceneStorage("venue.sort") private var venueSort = RankingSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = RankingSort.alphabetical
  @SceneStorage("navigation.state") private var archiveNavigation = ArchiveNavigation()
  @SceneStorage("nearby.state") private var nearbyModel = NearbyModel()

  @State private var activity = ArchiveActivity.none

  @ViewBuilder private var archiveBody: some View {
    ArchiveCategorySplit(
      model: model, venueSort: $venueSort, artistSort: $artistSort,
      selectedCategory: $archiveNavigation.category, path: $archiveNavigation.path,
      nearbyModel: nearbyModel)
  }

  var body: some View {
    archiveBody
      .onAppear { activity = archiveNavigation.activity }
      .onChange(of: archiveNavigation.activity) { _, newValue in
        activity = newValue
      }
      .onContinueUserActivity(ArchivePath.activityType) { archiveNavigation.pathActivity($0) }
      .onContinueUserActivity(ArchiveCategory.activityType) {
        archiveNavigation.categoryActivity($0)
      }
      .onOpenURL { archiveNavigation.openURL($0) }
      .advertiseUserActivity(
        for: activity,
        urlForCategory: { category in
          guard let category else { return nil }
          return model.vault.categoryURLMap[category]
        }
      ) { model.vault.restorableSharableLinkable(for: $0) }
  }
}

#Preview {
  ArchiveStateView(model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
