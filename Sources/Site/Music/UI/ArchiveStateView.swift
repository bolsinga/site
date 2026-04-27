//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI
import os

extension Logger {
  fileprivate static let dataError = Logger(category: "dataError")
}

struct ArchiveStateView: View {
  @Environment(VaultModel.self) var model

  @SceneStorage("venue.sort") private var venueSort = RankingSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = RankingSort.alphabetical
  @SceneStorage("navigation.state") private var archiveNavigation = ArchiveNavigation()
  @SceneStorage("nearby.state") private var nearbyModel = NearbyModel()

  let reloadModel: @MainActor () async -> Void

  @ViewBuilder private var archiveBody: some View {
    Group {
      if let error = model.error {
        VStack(alignment: .center) {
          ContentUnavailableView(
            error.localizedDescription, systemImage: "gear.badge.questionmark",
            description: Text("Invalid Data."))
          Button {
            Task {
              Logger.dataError.log("User retry")
              await reloadModel()
            }
          } label: {
            Label(String(localized: "Retry"), systemImage: "arrow.clockwise")
          }
          .buttonStyle(.borderedProminent)
        }
      } else {
        ArchiveTabView(
          showsMode: $archiveNavigation.mode,
          venueSort: $venueSort, artistSort: $artistSort,
          activeCategory: $archiveNavigation.category,
          pathForCategory: {
            switch $0 {
            case .today:
              return $archiveNavigation.state.todayPath
            case .stats, .settings, .search:
              return .constant([])
            case .shows:
              return $archiveNavigation.state.showsPath
            case .venues:
              return $archiveNavigation.state.venuesPath
            case .artists:
              return $archiveNavigation.state.artistsPath
            }
          }, reloadModel: reloadModel
        ) { archiveNavigation.navigate(to: $0) }
      }
    }
    .environment(nearbyModel)
  }

  var body: some View {
    archiveBody
      .onContinueUserActivity(ArchivePath.activityType) { archiveNavigation.pathActivity($0) }
      .onContinueUserActivity(ArchiveCategory.activityType) {
        archiveNavigation.categoryActivity($0)
      }
      .onOpenURL { archiveNavigation.openURL($0) }
      #if !os(tvOS)
        .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
      #endif
      .advertiseUserActivity(
        for: archiveNavigation.activity, urlForCategory: { model.vault.url(for: $0) }
      ) {
        model.vault.restorableSharableLinkable(for: $0)
      }
  }
}

#Preview("App", traits: .vaultModel) {
  ArchiveStateView {}
}

#Preview("Error", traits: .vaultModelWithError) {
  ArchiveStateView {}
}
