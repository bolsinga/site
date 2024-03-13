//
//  NSUserActivity+ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Foundation
import os

extension NSUserActivity {
  private enum DecodeError: Error {
    case noUserInfo
    case noArchiveKey
    case archiveKeyIncorrectType
  }

  internal static let archivePathKey = "archivePath"

  func update<T: PathRestorableUserActivity>(_ item: T, url: URL?) {
    let updateActivity = Logger(category: "updateActivity")

    let identifier = item.archivePath.formatted(.json)
    updateActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    if let url {
      updateActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    item.updateActivity(self)

    self.requiredUserInfoKeys = [NSUserActivity.archivePathKey]
    self.addUserInfoEntries(from: [NSUserActivity.archivePathKey: identifier])

    self.expirationDate = .now + (60 * 60 * 24)
  }

  func archivePath(_ logger: Logger? = nil) throws -> ArchivePath {
    logger?.log("type: \(self.activityType, privacy: .public)")

    guard let userInfo = self.userInfo else {
      logger?.error("no userInfo")
      throw DecodeError.noUserInfo
    }

    guard let value = userInfo[NSUserActivity.archivePathKey] else {
      logger?.error("no archivePathKey")
      throw DecodeError.noArchiveKey
    }

    guard let archiveString = value as? String else {
      logger?.error("archivePathKey not String")
      throw DecodeError.archiveKeyIncorrectType
    }

    logger?.log("decode: \(archiveString, privacy: .public)")

    return try ArchivePath(archiveString)
  }
}
