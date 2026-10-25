//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import Shared
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
  @SceneStorage("shows.sort.descending") private var showsDescending = false

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
          venueSort: $venueSort,
          artistSort: $artistSort,
          venuesMode: $venuesMode,
          showsDescending: $showsDescending,
          activeCategory: $archiveNavigation.category,
          pathForCategory: {
            switch $0 {
            case .today:
              return $archiveNavigation.state.todayPath
            case .settings, .search:
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
    .environment(\.archiveNavigationState, archiveNavigation.state)
  }

  /// The sort of the category being shown, which Handoff carries.
  private var categorySort: ArchiveCategorySort? {
    switch archiveNavigation.category {
    case .venues: .venues(venueSort)
    case .artists: .artists(artistSort)
    case .shows: .shows(descending: showsDescending)
    case .today, .settings, .search: nil
    }
  }

  private func apply(_ sort: ArchiveCategorySort) {
    switch sort {
    case .venues(let algorithm): venueSort = algorithm
    case .artists(let algorithm): artistSort = algorithm
    case .shows(let descending): showsDescending = descending
    }
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
          if let sort = activity.archiveCategorySort { apply(sort) }
          // Only the list is sorted, so a map would hide the order that was handed off.
          if activity.archiveCategory == .venues { venuesMode = .grouped }
        }
        self.pendingExternalEvent = nil
      }
      .advertiseUserActivity(
        for: archiveNavigation.activity, urlForCategory: { model.vault.url(for: $0) },
        categorySort: categorySort
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
