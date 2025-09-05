//
//  ArchiveNavigation+External.swift
//  site
//
//  Created by Greg Bolsinga on 11/12/24.
//

import Foundation
import MusicData
import Utilities
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

  func openURL(_ url: URL) {
    Logger.externalEvent.log("openURL: \(url.absoluteString, privacy: .public)")
    if let archivePath = try? ArchivePath(url) {
      self.navigate(to: archivePath)
    } else {
      Logger.externalEvent.error("url not path")

      if let archiveCategory = try? ArchiveCategory(url) {
        self.navigate(to: archiveCategory)
      } else {
        Logger.externalEvent.error("url not category")
      }
    }
  }
}
