//
//  NSUserActivity+ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import Foundation
import os

extension Logger {
  public static let updateActivity = Logger(category: "updateActivity")
  public static let decodeActivity = Logger(category: "decodeActivity")
}

extension NSUserActivity {
  private enum DecodeError: Error {
    case noUserInfo
    case noArchiveKey
    case archiveKeyIncorrectType
  }

  private static let archiveKey = "archive"

  func update<T: PathRestorableUserActivity>(_ item: T, vault: Vault) {
    let archivePath = item.archivePath

    let identifier = archivePath.formatted(.json)
    Logger.updateActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    if let url = vault.createURL(for: archivePath) {
      Logger.updateActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    item.updateActivity(self, vault: vault)

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
