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

protocol PathRestorableUserActivity: PathRestorable {
  var url: URL? { get }
  func updateActivity(_ userActivity: NSUserActivity)
}

struct ArchiveNavigationUserActivityModifier: ViewModifier {
  let archiveNavigation: ArchiveNavigation
  let urlForCategory: (ArchiveCategory) -> URL?
  let activityForPath: (ArchivePath) -> PathRestorableUserActivity?

  @State private var userActivityCategory: ArchiveNavigation.State.DefaultCategory =
    ArchiveNavigation.State.defaultCategory
  @State private var userActivityPath: [ArchivePath] = []

  func body(content: Content) -> some View {
    let isCategoryActive = {
      #if os(iOS) || os(tvOS)
        guard let userActivityCategory else { return false }
      #endif
      return archiveNavigation.userActivityActive(for: userActivityCategory)
    }()

    let isPathActive =
      !isCategoryActive
      && {
        guard let lastPath = userActivityPath.last else { return false }
        return archiveNavigation.userActivityActive(for: lastPath)
      }()

    #if os(iOS) || os(tvOS)
      Logger.navigationUserActivity.log(
        "\(userActivityCategory?.rawValue ?? "nil", privacy: .public): \(isCategoryActive, privacy: .public) \(userActivityPath, privacy: .public): \(isPathActive)"
      )
    #elseif os(macOS)
      Logger.navigationUserActivity.log(
        "\(userActivityCategory.rawValue, privacy: .public): \(isCategoryActive, privacy: .public) \(userActivityPath, privacy: .public): \(isPathActive)"
      )
    #endif

    return
      content
      .onAppear {
        userActivityCategory = archiveNavigation.category
        userActivityPath = archiveNavigation.path
      }
      .onChange(of: archiveNavigation.category) { _, newValue in
        userActivityCategory = newValue
      }
      .onChange(of: archiveNavigation.path) { _, newValue in
        userActivityPath = newValue
      }
      .userActivity(ArchiveCategory.activityType, isActive: isCategoryActive) { userActivity in
        #if os(iOS) || os(tvOS)
          guard let userActivityCategory else { return }
        #endif
        Logger.navigationUserActivity.log(
          "update category \(userActivityCategory.rawValue, privacy: .public)")
        userActivity.update(userActivityCategory, url: urlForCategory(userActivityCategory))
      }
      .userActivity(ArchivePath.activityType, isActive: isPathActive) { userActivity in
        guard let lastPath = userActivityPath.last else { return }
        Logger.navigationUserActivity.log(
          "update path \(lastPath.formatted(.json), privacy: .public)")
        guard let pathUserActivity = activityForPath(lastPath) else { return }
        userActivity.update(pathUserActivity)
      }
  }
}

extension View {
  func advertiseUserActivity(
    for archiveNavigation: ArchiveNavigation, urlForCategory: @escaping (ArchiveCategory) -> URL?,
    activityForPath: @escaping (ArchivePath) -> PathRestorableUserActivity?
  ) -> some View {
    modifier(
      ArchiveNavigationUserActivityModifier(
        archiveNavigation: archiveNavigation, urlForCategory: urlForCategory,
        activityForPath: activityForPath))
  }
}
