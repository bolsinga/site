//
//  ArchiveNavigation+External.swift
//  site
//
//  Created by Greg Bolsinga on 11/12/24.
//

import Foundation
import Shared
import os

extension Logger {
  fileprivate static let externalEvent = Logger(category: "externalEvent")
}

extension ArchiveNavigation {
  func pathActivity(_ userActivity: NSUserActivity) {
    Logger.externalEvent.log(
      "userActivity: \(ArchivePath.activityType, privacy: .public)")

    guard let path = userActivity.archivePath else {
      Logger.externalEvent.error("no path")
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
  @discardableResult
  func openURL(_ url: URL) -> ArchiveCategory? {
    Logger.externalEvent.log("openURL: \(url.absoluteString, privacy: .public)")
    if let archivePath = try? ArchivePath(url) {
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
