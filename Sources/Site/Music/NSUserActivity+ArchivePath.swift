//
//  NSUserActivity+ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Foundation
import os

extension Logger {
  public static let updateActivity = Logger(
    subsystem: Bundle.main.bundleIdentifier!, category: "updateActivity")

  public static let decodeActivity = Logger(
    subsystem: Bundle.main.bundleIdentifier!, category: "decodeActivity")
}

extension NSUserActivity {
  func update<T: PathRestorableUserActivity>(_ item: T, url: URL?) throws {
    let archivePath = item.archivePath

    let identifier = archivePath.formatted()
    Logger.updateActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    if let url {
      Logger.updateActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    item.updateActivity(self)

    try self.setTypedPayload(archivePath)
  }

  func archivePath() throws -> ArchivePath {
    Logger.decodeActivity.log("type: \(self.activityType, privacy: .public)")
    return try self.typedPayload(ArchivePath.self)
  }
}
