//
//  CategoryDetailModifier.swift
//  site
//
//  Created by Greg Bolsinga on 9/21/24.
//

import SwiftUI

struct CategoryDetailModifier: ViewModifier {
  let vault: Vault
  let category: ArchiveCategory
  @Binding var path: [ArchivePath]

  func body(content: Content) -> some View {
    NavigationStack(path: $path) {
      content
        .archiveShare(ArchiveCategoryLinkable(vault: vault, category: category))
        .musicDestinations(vault, path: path)
    }
  }
}

extension View {
  func categoryDetail(vault: Vault, category: ArchiveCategory, path: Binding<[ArchivePath]>)
    -> some View
  {
    modifier(CategoryDetailModifier(vault: vault, category: category, path: path))
  }
}
