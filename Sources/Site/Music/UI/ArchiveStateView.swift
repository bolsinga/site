//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

struct ArchiveStateView: View {
  var model: VaultModel

  @SceneStorage("venue.sort") private var venueSort = RankingSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = RankingSort.alphabetical

  @State private var archiveNavigation = ArchiveNavigation()
  @State private var nearbyModel: NearbyModel

  internal init(model: VaultModel) {
    self.model = model
    self.nearbyModel = NearbyModel(vaultModel: model)
  }

  var body: some View {
    #if os(iOS)
      ArchiveTabView(
        model: model, venueSort: $venueSort, artistSort: $artistSort,
        archiveNavigation: archiveNavigation, nearbyModel: nearbyModel)
    #elseif os(tvOS) || os(macOS)
      ArchiveCategorySplit(
        model: model, venueSort: $venueSort, artistSort: $artistSort,
        archiveNavigation: archiveNavigation, nearbyModel: nearbyModel)
    #endif
  }
}

#Preview {
  ArchiveStateView(model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
