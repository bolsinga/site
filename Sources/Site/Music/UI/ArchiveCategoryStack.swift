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
  let statsDisplayArchiveCategoryCounts: Bool
  @Binding var path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  let nearbyModel: NearbyModel

  var body: some View {
    NavigationStack(path: $path) {
      ArchiveCategoryRoot(
        category: category, statsDisplayArchiveCategoryCounts: statsDisplayArchiveCategoryCounts,
        venueSort: $venueSort, artistSort: $artistSort, nearbyModel: nearbyModel
      )
      .navigationDestination(for: ArchivePath.self) {
        $0.destination(vault: model.vault, isPathNavigable: path.isPathNavigable(_:))
      }
    }
  }
}

// Preview only extension
extension ArchiveCategoryStack {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      category: category, statsDisplayArchiveCategoryCounts: false, path: .constant([]),
      venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), nearbyModel: NearbyModel())
  }
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .today)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .stats)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .shows)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .venues)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .artists)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
