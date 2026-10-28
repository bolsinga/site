//
//  NSUserActivity+ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import Foundation
import Intents
import Shared
import os

extension Logger {
  fileprivate static let updateCategoryActivity = Logger(category: "updateCategoryActivity")
  fileprivate static let decodeCategoryActivity = Logger(category: "decodeCategoryActivity")
}

extension NSUserActivity {
  internal static let archiveCategoryKey = "archiveCategory"

  /// The categories were once saved as shortcuts. Opening them is an intent now, so the saved ones go.
  static func deleteSavedCategoryActivities() {
    #if !os(tvOS)
      let key = "deletedSavedCategoryActivities"
      guard !UserDefaults.standard.bool(forKey: key) else { return }
      deleteSavedUserActivities(
        withPersistentIdentifiers: ArchiveCategory.allCases.map(\.rawValue)
      ) {
        UserDefaults.standard.set(true, forKey: key)
      }
    #endif
  }

  func update(_ category: ArchiveCategory, url: URL?, sort: ArchiveCategorySort? = nil) {
    let identifier = category.rawValue
    Logger.updateCategoryActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    self.isEligibleForHandoff = true

    self.title = category.title

    if let url {
      Logger.updateCategoryActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    var entries: [String: Any] = [NSUserActivity.archiveCategoryKey: identifier]
    if let sort {
      entries.merge(NSUserActivity.userInfoEntries(for: sort)) { $1 }
    }
    self.requiredUserInfoKeys = Set(entries.keys)
    self.addUserInfoEntries(from: entries)

    self.expirationDate = .now + (60 * 60 * 24)
  }

  var archiveCategory: ArchiveCategory? {
    Logger.decodeCategoryActivity.log("type: \(self.activityType, privacy: .public)")

    guard let userInfo = self.userInfo else {
      Logger.decodeCategoryActivity.error("no userInfo")
      return nil
    }

    guard let value = userInfo[NSUserActivity.archiveCategoryKey] else {
      Logger.decodeCategoryActivity.error("no archiveCategoryKey")
      return nil
    }

    guard let archiveCategoryString = value as? String else {
      Logger.decodeCategoryActivity.error("archiveCategoryKey not String")
      return nil
    }

    Logger.decodeCategoryActivity.log("decode: \(archiveCategoryString, privacy: .public)")

    guard let category = ArchiveCategory(rawValue: archiveCategoryString) else {
      return nil
    }

    return category
  }
}
