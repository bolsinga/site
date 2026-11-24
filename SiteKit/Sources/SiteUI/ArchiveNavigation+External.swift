//
//  ArchiveNavigation+External.swift
//  site
//
//  Created by Greg Bolsinga on 11/12/24.
//

import Foundation
import SiteCore
import os

extension Logger {
  fileprivate static let externalEvent = Logger(category: "externalEvent")
}

extension ArchiveNavigation {
  /// A page the archive doesn't have opens its category's list, since there's nothing to show.
  func pathActivity(
    _ userActivity: NSUserActivity, exists: (ArchivePath) -> Bool = { _ in true }
  ) {
    Logger.externalEvent.log(
      "userActivity: \(ArchivePath.activityType, privacy: .public)")

    guard let path = userActivity.archivePath else {
      Logger.externalEvent.error("no path")
      return
    }
    guard exists(path) else {
      Logger.externalEvent.error("path not in the archive")
      self.navigate(toRootOf: path.category)
      return
    }
    self.navigate(to: path)
  }

  func categoryActivity(_ userActivity: NSUserActivity) {
    Logger.externalEvent.log(
      "userActivity: \(ArchiveCategory.activityType, privacy: .public)")

    guard let category = userActivity.archiveCategory else {
      Logger.externalEvent.error("no category")
      return
    }
    self.navigate(to: category)
  }

  /// Returns the category whose list the URL opened, or nil when it opened a page or nothing.
  /// A page the archive doesn't have opens its category's list.
  @discardableResult
  func openURL(_ url: URL, exists: (ArchivePath) -> Bool = { _ in true }) -> ArchiveCategory? {
    Logger.externalEvent.log("openURL: \(url.absoluteString, privacy: .public)")
    if let archivePath = try? ArchivePath(url) {
      guard exists(archivePath) else {
        Logger.externalEvent.error("path not in the archive")
        self.navigate(toRootOf: archivePath.category)
        return archivePath.category
      }
      self.navigate(to: archivePath)
      return nil
    }
    Logger.externalEvent.error("url not path")

    guard let archiveCategory = try? ArchiveCategory(url) else {
      Logger.externalEvent.error("url not category")
      return nil
    }
    // A link to a category (e.g. the Shows Today widget) means its list, not a page left open.
    self.navigate(toRootOf: archiveCategory)
    return archiveCategory
  }
}
