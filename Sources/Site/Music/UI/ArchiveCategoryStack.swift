//
//  ArchiveCategoryStack.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import Shared
import SwiftUI

struct ArchiveCategoryStack: View {
  @Environment(VaultModel.self) var model
  @Environment(\.archiveNavigationState) private var navigationState

  let category: ArchiveCategory
  @Binding var path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  @Binding var venuesMode: VenuesMode
  @Binding var dayOfLeapYear: Int

  let reloadModel: @MainActor () async -> Void
  let navigateToPath: (ArchivePath) -> Void

  @State private var artistSearchString: String = ""
  @State private var venueSearchString: String = ""

  /// The navigation state the settings sheet was presented in. The sheet only shows while the
  /// state is unchanged, so an external URL or activity that navigates dismisses it.
  @State private var settingsPresentedState: ArchiveNavigation.State?

  private var showNearbyDistanceSettings: Binding<Bool> {
    Binding(
      get: { settingsPresentedState == navigationState },
      set: { settingsPresentedState = $0 ? navigationState : nil })
  }

  @ViewBuilder private var summary: some View {
    switch category {
    case .today:
      DaySummary(dayOfLeapYear: $dayOfLeapYear)
    case .shows:
      ShowsSummary()
    case .venues:
      VenuesSummary(
        sort: venueSort,
        searchString: $venueSearchString,
        mode: $venuesMode,
        navigateToPath: navigateToPath)
    case .artists:
      ArtistsSummary(sort: artistSort, searchString: $artistSearchString)
    case .settings:
      SettingsView()
    case .search:
      EmptyView()
    }
  }

  var body: some View {
    NavigationStack(path: $path) {
      summary
        .refreshable { await reloadModel() }
        .sheet(isPresented: showNearbyDistanceSettings) {
          SettingsView()
            .presentationDetents([.medium])
        }
        .navigationDestination(for: ArchivePath.self) {
          $0.destination(vault: model.vault, isPathNavigable: path.isPathNavigable(_:))
        }
        .toolbar {
          ArchiveCategoryToolbarContent(
            category: category,
            venueSort: $venueSort,
            artistSort: $artistSort,
            showNearbyDistanceSettings: showNearbyDistanceSettings,
            venuesMode: $venuesMode)
        }
    }
  }
}

// Preview only extension
extension ArchiveCategoryStack {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      category: category,
      path: .constant([]),
      venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical),
      venuesMode: .constant(.default),
      dayOfLeapYear: .constant(Date.now.dayOfLeapYear),
      reloadModel: {},
      navigateToPath: { _ in })
  }
}

#Preview("Today", traits: .nearbyModel, .vaultModel) {
  ArchiveCategoryStack(withPreviewCategory: .today)
}

#Preview("Shows", traits: .nearbyModel, .vaultModel) {
  ArchiveCategoryStack(withPreviewCategory: .shows)
}

#Preview("Venues", traits: .nearbyModel, .vaultModel) {
  ArchiveCategoryStack(withPreviewCategory: .venues)
}

#Preview("Artists", traits: .nearbyModel, .vaultModel) {
  ArchiveCategoryStack(withPreviewCategory: .artists)
}
