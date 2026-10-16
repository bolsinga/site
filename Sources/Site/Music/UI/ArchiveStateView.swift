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
  @SceneStorage("venues.mode") private var venuesMode = VenuesMode.default

  @Binding var pendingExternalEvent: ExternalEvent?
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
          venueSort: $venueSort,
          artistSort: $artistSort,
          venuesMode: $venuesMode,
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
      .onChange(of: pendingExternalEvent?.id, initial: true) {
        guard let pendingExternalEvent else { return }
        switch pendingExternalEvent.kind {
        case .url(let url):
          archiveNavigation.openURL(url)
        case .path(let activity):
          archiveNavigation.pathActivity(activity)
        case .category(let activity):
          archiveNavigation.categoryActivity(activity)
        }
        self.pendingExternalEvent = nil
      }
      .advertiseUserActivity(
        for: archiveNavigation.activity, urlForCategory: { model.vault.url(for: $0) }
      ) {
        model.vault.restorableSharableLinkable(for: $0)
      }
  }
}

#Preview("App", traits: .vaultModel) {
  @Previewable @State var pendingExternalEvent: ExternalEvent?
  ArchiveStateView(pendingExternalEvent: $pendingExternalEvent) {}
}

#Preview("Error", traits: .vaultModelWithError) {
  @Previewable @State var pendingExternalEvent: ExternalEvent?
  ArchiveStateView(pendingExternalEvent: $pendingExternalEvent) {}
}
