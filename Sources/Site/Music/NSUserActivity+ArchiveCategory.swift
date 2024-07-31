//
//  NSUserActivity+ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import Foundation
import Intents
import os

extension Logger {
  nonisolated(unsafe) static let updateCategoryActivity = Logger(category: "updateCategoryActivity")
  nonisolated(unsafe) static let decodeCategoryActivity = Logger(category: "decodeCategoryActivity")
  #if swift(>=6.0)
    #warning("nonisolated(unsafe) unneeded.")
  #endif
}

extension NSUserActivity {
  private enum DecodeError: Error {
    case noUserInfo
    case noArchiveKey
    case archiveKeyIncorrectType
    case invalidArchiveCategoryString
  }

  internal static let archiveCategoryKey = "archiveCategory"

  func update(_ category: ArchiveCategory, url: URL?) {
    let identifier = category.rawValue
    Logger.updateCategoryActivity.log("advertise: \(identifier, privacy: .public)")
    self.targetContentIdentifier = identifier

    self.isEligibleForHandoff = true

    self.title = category.title

    #if !os(tvOS)
      self.persistentIdentifier = category.rawValue
    #endif
    if category == .today {
      #if os(iOS)
        self.isEligibleForPrediction = true
      #endif
      #if !os(tvOS)
        self.suggestedInvocationPhrase = String(localized: "Shows Today", bundle: .module)
      #endif
    }

    if let url {
      Logger.updateCategoryActivity.log("web: \(url.absoluteString, privacy: .public)")
      self.isEligibleForPublicIndexing = true
      self.webpageURL = url
    }

    self.requiredUserInfoKeys = [NSUserActivity.archiveCategoryKey]
    self.addUserInfoEntries(from: [NSUserActivity.archiveCategoryKey: identifier])

    self.expirationDate = .now + (60 * 60 * 24)
  }

  func archiveCategory() throws -> ArchiveCategory {
    Logger.decodeCategoryActivity.log("type: \(self.activityType, privacy: .public)")

    guard let userInfo = self.userInfo else {
      Logger.decodeCategoryActivity.error("no userInfo")
      throw DecodeError.noUserInfo
    }

    guard let value = userInfo[NSUserActivity.archiveCategoryKey] else {
      Logger.decodeCategoryActivity.error("no archiveCategoryKey")
      throw DecodeError.noArchiveKey
    }

    guard let archiveCategoryString = value as? String else {
      Logger.decodeCategoryActivity.error("archiveCategoryKey not String")
      throw DecodeError.archiveKeyIncorrectType
    }

    Logger.decodeCategoryActivity.log("decode: \(archiveCategoryString, privacy: .public)")

    guard let category = ArchiveCategory(rawValue: archiveCategoryString) else {
      throw DecodeError.invalidArchiveCategoryString
    }

    return category
  }
}
