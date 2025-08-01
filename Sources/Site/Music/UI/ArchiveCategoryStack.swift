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

  var body: some View {
    NavigationStack(path: $path) {
      ArchiveCategoryRoot(
        category: category, statsDisplayArchiveCategoryCounts: statsDisplayArchiveCategoryCounts,
        venueSort: $venueSort, artistSort: $artistSort
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
      artistSort: .constant(.alphabetical))
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .today)
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .stats)
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .shows)
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .venues)
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  ArchiveCategoryStack(withPreviewCategory: .artists)
}
