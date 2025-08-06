//
//  ArchiveCategoryRoot.swift
//  site
//
//  Created by Greg Bolsinga on 10/14/24.
//

import SwiftUI

struct ArchiveCategoryRoot: View {
  @Environment(VaultModel.self) var model

  let category: ArchiveCategory
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
      ShowsSummary()
    case .venues:
      VenuesSummary(sort: venueSort, searchString: $venueSearchString)
    case .artists:
      ArtistsSummary(sort: artistSort, searchString: $artistSearchString)
    case .settings:
      SettingsView()
    }
  }

  var body: some View {
    summary
      .refreshable { await reloadModel() }
      .toolbar {
        ArchiveCategoryToolbarContent(
          category: category, venueSort: $venueSort, artistSort: $artistSort,
          showNearbyDistanceSettings: $showNearbyDistanceSettings)
      }
      .sheet(isPresented: $showNearbyDistanceSettings) { SettingsView() }
  }
}

// Preview only extension
extension ArchiveCategoryRoot {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      category: category, venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
      reloadModel: {})
  }
}

#Preview("Today", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .today)
}

#Preview("Stats", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .stats)
}

#Preview("Shows", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .shows)
}

#Preview("Venues", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .venues)
}

#Preview("Artists", traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveCategoryRoot(withPreviewCategory: .artists)
}
