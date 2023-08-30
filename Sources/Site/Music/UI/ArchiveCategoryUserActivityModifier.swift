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
  let category: ArchiveCategory
  let url: URL?

  @Binding var isActive: Bool

  func body(content: Content) -> some View {
    content
      .userActivity(ArchiveCategory.activityType, isActive: isActive) { userActivity in
        userActivity.update(category, url: url)
      }
  }
}

extension View {
  func archiveCategoryUserActivity(_ category: ArchiveCategory, url: URL?, isActive: Binding<Bool>)
    -> some View
  {
    modifier(ArchiveCategoryUserActivityModifier(category: category, url: url, isActive: isActive))
  }
}
