//
//  NSUserActivity+ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Foundation
import os

extension Logger {
  #if swift(>=6.0)
    static let updateActivity = Logger(category: "updateActivity")
    static let decodeActivity = Logger(category: "decodeActivity")
  #else
    nonisolated(unsafe) static let updateActivity = Logger(category: "updateActivity")
    nonisolated(unsafe) static let decodeActivity = Logger(category: "decodeActivity")
  #endif
}

extension NSUserActivity {
  internal static let archivePathKey = "archivePath"

  func update<T: PathRestorableUserActivity>(_ item: T, url: URL?) {
    let identifier = item.archivePath.formatted(.json)
    Logger.updateActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    if let url {
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
