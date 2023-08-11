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

  @Binding var isActive: Bool

  func body(content: Content) -> some View {
    content
      .userActivity(ArchiveCategory.activityType, isActive: isActive) { userActivity in
        userActivity.update(category, vault: vault)
      }
  }
}

extension View {
  func archiveCategoryUserActivity(_ category: ArchiveCategory, isActive: Binding<Bool>)
    -> some View
  {
    modifier(ArchiveCategoryUserActivityModifier(category: category, isActive: isActive))
  }
}
