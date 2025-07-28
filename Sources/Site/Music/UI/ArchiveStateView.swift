//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

struct ArchiveStateView: View {
  @Environment(VaultModel.self) var model

  @SceneStorage("venue.sort") private var venueSort = RankingSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = RankingSort.alphabetical
  @SceneStorage("navigation.state") private var archiveNavigation = ArchiveNavigation()
  @SceneStorage("nearby.state") private var nearbyModel = NearbyModel()

  @State private var activity = ArchiveActivity.category(.defaultCategory)

  @ViewBuilder private var archiveBody: some View {
    ArchiveTabView(
      venueSort: $venueSort, artistSort: $artistSort,
      selectedCategory: $archiveNavigation.category,
      pathForCategory: {
        switch $0 {
        case .today:
          return $archiveNavigation.state.todayPath
        case .stats, .settings:
          return .constant([])
        case .shows:
          return $archiveNavigation.state.showsPath
        case .venues:
          return $archiveNavigation.state.venuesPath
        case .artists:
          return $archiveNavigation.state.artistsPath
        }
      }, nearbyModel: nearbyModel)
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
      .advertiseUserActivity(for: activity, urlForCategory: { model.vault.categoryURLMap[$0] }) {
        model.vault.restorableSharableLinkable(for: $0)
      }
  }
}

#Preview {
  ArchiveStateView()
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
