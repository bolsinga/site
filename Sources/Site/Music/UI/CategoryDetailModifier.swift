//
//  CategoryDetailModifier.swift
//  site
//
//  Created by Greg Bolsinga on 9/21/24.
//

import SwiftUI

struct CategoryDetailModifier: ViewModifier {
  let vault: Vault
  let nearbyModel: NearbyModel
  let category: ArchiveCategory
  @Binding var path: [ArchivePath]

  func body(content: Content) -> some View {
    NavigationStack(path: $path) {
      content
        .archiveShare(category, url: vault.categoryURLMap[category])
        .shareActivity(for: category, vault: vault)
        .musicDestinations(vault, path: path)
        #if !os(macOS)
          .nearbyDistanceThreshold(nearbyModel)
        #endif
    }
  }
}

extension View {
  func categoryDetail(
    vault: Vault, nearbyModel: NearbyModel, category: ArchiveCategory, path: Binding<[ArchivePath]>
  ) -> some View {
    modifier(
      CategoryDetailModifier(vault: vault, nearbyModel: nearbyModel, category: category, path: path)
    )
  }
}
