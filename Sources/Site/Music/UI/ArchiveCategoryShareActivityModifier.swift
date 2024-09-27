//
//  ArchiveCategoryShareActivityModifier.swift
//
//
//  Created by Greg Bolsinga on 8/3/24.
//

import SwiftUI
import os

extension Logger {
  fileprivate static let sharing = Logger(category: "sharing")
}

struct ArchiveCategoryShareActivityModifier: ViewModifier {
  let category: ArchiveCategory
  let vault: Vault
  let isActive: Bool

  func body(content: Content) -> some View {
    let url = vault.categoryURLMap[category]
    Logger.sharing.log(
      "\(category.rawValue, privacy: .public), active: \(isActive, privacy: .public), url: \(url?.absoluteString ?? "nil", privacy: .public)"
    )
    return
      content
      .archiveShare(category, url: url)
      .archiveCategoryUserActivity(category, url: url, isActive: isActive)
  }
}

extension View {
  func shareActivity(for category: ArchiveCategory, vault: Vault, isActive: Bool) -> some View {
    modifier(
      ArchiveCategoryShareActivityModifier(category: category, vault: vault, isActive: isActive))
  }
}
