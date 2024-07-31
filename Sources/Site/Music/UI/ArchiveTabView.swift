//
//  ArchiveTabView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

struct ArchiveTabView: View {
  var model: VaultModel

  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  @Bindable var archiveNavigation: ArchiveNavigation
  var nearbyModel: NearbyModel

  var body: some View {
    TabView {
      ArchiveCategorySplit(
        model: model, venueSort: $venueSort, artistSort: $artistSort,
        archiveNavigation: archiveNavigation, nearbyModel: nearbyModel
      )
      .tabItem { ArchiveTab.classic.label }
    }
  }
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  return ArchiveTabView(
    model: vaultModel, venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    archiveNavigation: ArchiveNavigation(), nearbyModel: NearbyModel(vaultModel: vaultModel))
}
