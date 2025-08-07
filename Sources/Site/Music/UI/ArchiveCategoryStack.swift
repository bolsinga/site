//
//  ArchiveCategoryStack.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import SwiftUI

struct ArchiveCategoryStack: View {
  @Environment(VaultModel.self) var model

  let category: ArchiveCategory
  @Binding var showsMode: ShowsMode
  @Binding var path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  let reloadModel: @MainActor () async -> Void

  @State private var artistSearchString: String = ""
  @State private var venueSearchString: String = ""

  @State private var showNearbyDistanceSettings: Bool = false

  @ViewBuilder private var summary: some View {
    switch category {
    case .today:
      TodaySummary()
    case .stats:
      StatsSummary()
    case .shows:
      if combineTodayAndShowSummary {
        DaysShowsSummary(mode: $showsMode)
      } else {
        ShowsSummary()
      }
    case .venues:
      VenuesSummary(sort: venueSort, searchString: $venueSearchString)
    case .artists:
      ArtistsSummary(sort: artistSort, searchString: $artistSearchString)
    case .settings:
      SettingsView()
    }
  }

  var body: some View {
    NavigationStack(path: $path) {
      summary
        .refreshable { await reloadModel() }
        .sheet(isPresented: $showNearbyDistanceSettings) { SettingsView() }
        .navigationDestination(for: ArchivePath.self) {
          $0.destination(vault: model.vault, isPathNavigable: path.isPathNavigable(_:))
        }
        .toolbar {
          ArchiveCategoryToolbarContent(
            category: category, venueSort: $venueSort, artistSort: $artistSort,
            showNearbyDistanceSettings: $showNearbyDistanceSettings)
        }
    }
  }
}

// Preview only extension
extension ArchiveCategoryStack {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      category: category, showsMode: .constant(.ordinal), path: .constant([]),
      venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), reloadModel: {})
  }
}

#Preview("Today", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .today)
}

#Preview("Stats", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .stats)
}

#Preview("Shows", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .shows)
}

#Preview("Venues", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .venues)
}

#Preview("Artists", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .artists)
}
