//
//  ArchiveCategoryUserActivityModifier.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import SwiftUI
import os

extension ArchiveCategory {
  static let activityType = "gdb.SiteApp.view-archiveCategory"
}

extension Logger {
  fileprivate static let categoryActivity = Logger(category: "categoryActivity")
}

struct ArchiveCategoryUserActivityModifier: ViewModifier {
  let category: ArchiveCategory
  let url: URL?
  let isActive: (ArchiveCategory) -> Bool

  func body(content: Content) -> some View {
    let isActive = isActive(category)
    Logger.categoryActivity.log(
      "\(category.rawValue, privacy: .public) active: \(isActive, privacy: .public)")
    return
      content
      .userActivity(ArchiveCategory.activityType, isActive: isActive) { userActivity in
        userActivity.update(category, url: url)
      }
  }
}

extension View {
  func archiveCategoryUserActivity(
    _ category: ArchiveCategory, url: URL?, isActive: @escaping ((ArchiveCategory) -> Bool)
  ) -> some View {
    modifier(ArchiveCategoryUserActivityModifier(category: category, url: url, isActive: isActive))
  }
}
