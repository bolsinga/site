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
  enum DecodeError: Error {
    case noUserInfo
    case noArchiveKey
    case archiveKeyIncorrectType
  }

  static let archiveKey = "archive"

  func update<T: PathRestorableUserActivity>(_ item: T, url: URL?) {
    let archivePath = item.archivePath

    let identifier = archivePath.formatted(.json)
    Logger.updateActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    if let url {
      Logger.updateActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    item.updateActivity(self)

    self.requiredUserInfoKeys = [NSUserActivity.archiveKey]
    self.addUserInfoEntries(from: [NSUserActivity.archiveKey: identifier])

    self.expirationDate = .now + (60 * 60 * 24)
  }

  func archivePath() throws -> ArchivePath {
    Logger.decodeActivity.log("type: \(self.activityType, privacy: .public)")

    guard let userInfo = self.userInfo else {
      Logger.decodeActivity.log("no userInfo")
      throw DecodeError.noUserInfo
    }

    guard let value = userInfo[NSUserActivity.archiveKey] else {
      Logger.decodeActivity.log("no archiveKey")
      throw DecodeError.noArchiveKey
    }

    guard let archiveString = value as? String else {
      Logger.decodeActivity.log("archiveKey not String")
      throw DecodeError.archiveKeyIncorrectType
    }

    Logger.decodeActivity.log("decode: \(archiveString, privacy: .public)")

    return try ArchivePath(archiveString)
  }
}
