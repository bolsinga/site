//
//  ArchiveNavigationUserActivityModifier.swift
//  site
//
//  Created by Greg Bolsinga on 9/29/24.
//

import SwiftUI
import os

extension ArchiveCategory {
  static let activityType = "gdb.SiteApp.view-archiveCategory"
}

extension ArchivePath {
  static let activityType = "gdb.SiteApp.view-archivePath"
}

extension Logger {
  fileprivate static let navigationUserActivity = Logger(category: "navigationUserActivity")
}

protocol PathRestorableUserActivity: Linkable, PathRestorable {
  func updateActivity(_ userActivity: NSUserActivity)
}

struct ArchiveNavigationUserActivityModifier: ViewModifier {
  let archiveNavigation: ArchiveNavigation
  let urlForCategory: (ArchiveCategory.DefaultCategory) -> URL?
  let activityForPath: (ArchivePath) -> PathRestorableUserActivity?

  @State private var activity = ArchiveActivity.none

  func body(content: Content) -> some View {
    Logger.navigationUserActivity.log("activity: \(activity, privacy: .public)")
    return
      content
      .onAppear { activity = archiveNavigation.activity }
      .onChange(of: archiveNavigation.activity) { _, newValue in
        activity = newValue
      }
      .userActivity(ArchiveCategory.activityType, isActive: activity.isCategory) { userActivity in
        switch activity {
        case .none, .path(_):
          return
        case .category(let archiveCategory):
          Logger.navigationUserActivity.log(
            "update category \(archiveCategory.rawValue, privacy: .public)")
          userActivity.update(archiveCategory, url: urlForCategory(archiveCategory))
        }
      }
      .userActivity(ArchivePath.activityType, isActive: activity.isPath) { userActivity in
        switch activity {
        case .none, .category(_):
          return
        case .path(let archivePath):
          Logger.navigationUserActivity.log(
            "update path \(archivePath.formatted(.json), privacy: .public)")
          guard let pathUserActivity = activityForPath(archivePath) else { return }
          userActivity.update(pathUserActivity)
        }
      }
  }
}

extension View {
  func advertiseUserActivity(
    for archiveNavigation: ArchiveNavigation,
    urlForCategory: @escaping (ArchiveCategory.DefaultCategory) -> URL?,
    activityForPath: @escaping (ArchivePath) -> PathRestorableUserActivity?
  ) -> some View {
    modifier(
      ArchiveNavigationUserActivityModifier(
        archiveNavigation: archiveNavigation, urlForCategory: urlForCategory,
        activityForPath: activityForPath))
  }
}
