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

struct ArchiveCategoryUserActivityModifier<T: RawRepresentable<String>>: ViewModifier {
  let category: T
  let url: (T) -> URL?
  let isActive: (T) -> Bool

  func body(content: Content) -> some View {
    let url = url(category)
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
  func archiveCategoryUserActivity<T: RawRepresentable<String>>(
    _ category: T, url: @escaping (T) -> URL?,
    isActive: @escaping ((T) -> Bool)
  ) -> some View {
    modifier(ArchiveCategoryUserActivityModifier(category: category, url: url, isActive: isActive))
  }
}
