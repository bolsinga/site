//
//  ArchiveCategoryUserActivityModifier.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import SwiftUI

extension ArchiveCategory {
  static let activityType = "gdb.SiteApp.view-archiveCategory"
}

struct ArchiveCategoryUserActivityModifier: ViewModifier {
  @Environment(\.vault) var vault: Vault

  let category: ArchiveCategory

  func body(content: Content) -> some View {
    content
      .userActivity(ArchiveCategory.activityType) { userActivity in
        userActivity.update(category, vault: vault)
      }
  }
}

extension View {
  func archiveCategoryUserActivity(_ category: ArchiveCategory) -> some View {
    modifier(ArchiveCategoryUserActivityModifier(category: category))
  }
}
