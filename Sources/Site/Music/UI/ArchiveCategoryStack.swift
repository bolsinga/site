//
//  ArchiveCategoryStack.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import SwiftUI

struct ArchiveCategoryStack: View {
  let model: VaultModel
  let category: ArchiveCategory
  @Binding var path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  let nearbyModel: NearbyModel

  @State var artistSearchString: String = ""
  @State var venueSearchString: String = ""

  var body: some View {
    NavigationStack(path: $path) {
      ArchiveCategoryRoot(
        model: model, category: category, venueSort: $venueSort, artistSort: $artistSort,
        nearbyModel: nearbyModel
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
      model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false),
      category: category, path: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), nearbyModel: NearbyModel())
  }
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .today)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .stats)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .shows)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .venues)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .artists)
}
