//
//  NSUserActivity+ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let updateActivity = Logger(category: "updateActivity")
  fileprivate static let decodeActivity = Logger(category: "decodeActivity")
}

extension NSUserActivity {
  internal static let archivePathKey = "archivePath"

  func update<T: PathRestorableUserActivity>(_ item: T) {
    let identifier = item.archivePath.formatted(.json)
    Logger.updateActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    if let url = item.url {
      Logger.updateActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    item.updateActivity(self)

    self.requiredUserInfoKeys = [NSUserActivity.archivePathKey]
    self.addUserInfoEntries(from: [NSUserActivity.archivePathKey: identifier])

    self.expirationDate = .now + (60 * 60 * 24)
  }

  var archivePath: ArchivePath? {
    Logger.decodeActivity.log("type: \(self.activityType, privacy: .public)")

    guard let userInfo = self.userInfo else {
      Logger.decodeActivity.error("no userInfo")
      return nil
    }

    guard let value = userInfo[NSUserActivity.archivePathKey] else {
      Logger.decodeActivity.error("no archivePathKey")
      return nil
    }

    guard let archiveString = value as? String else {
      Logger.decodeActivity.error("archivePathKey not String")
      return nil
    }

    Logger.decodeActivity.log("decode: \(archiveString, privacy: .public)")

    return try? ArchivePath(archiveString)
  }
}
