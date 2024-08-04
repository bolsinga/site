//
//  ArchiveCategoryShareActivityModifier.swift
//
//
//  Created by Greg Bolsinga on 8/3/24.
//

import SwiftUI

struct ArchiveCategoryShareActivityModifier: ViewModifier {
  let category: ArchiveCategory
  let vault: Vault
  let isActive: Bool

  func body(content: Content) -> some View {
    let url = vault.createURL(forCategory: category)
    content
      .shareCategory(category, url: url)
      .archiveCategoryUserActivity(category, url: url, isActive: isActive)
  }
}

extension View {
  func shareActivity(for category: ArchiveCategory, vault: Vault, isActive: Bool) -> some View {
    modifier(
      ArchiveCategoryShareActivityModifier(category: category, vault: vault, isActive: isActive))
  }
}
