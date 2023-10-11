//
//  ArchiveNavigation.swift
//
//
//  Created by Greg Bolsinga on 6/13/23.
//

import Combine
import Foundation
import os

extension Logger {
  static let archive = Logger(category: "archive")
}

@Observable final class ArchiveNavigation {
  var selectedCategory: ArchiveCategory?
  var navigationPath: [ArchivePath] = []

  @ObservationIgnored internal var pendingNavigationPath: [ArchivePath]?

  func restoreNavigation(selectedCategoryStorage: ArchiveCategory?, pathData: Data?) {
    if let selectedCategoryStorage {
      if let pathData {
        // Hold onto the loading navigationPath for after the selectedCategory changes.
        var pending = [ArchivePath]()
        pending.jsonData = pathData
        Logger.archive.log(
          "pending save: \(pending.map { $0.formatted() }.joined(separator: ":"), privacy: .public)"
        )
        pendingNavigationPath = pending
      }

      // Changing the selectedCategory will reset the NavigationStack's navigationPath.
      selectedCategory = selectedCategoryStorage
    } else {
      if let pathData {
        navigationPath.jsonData = pathData
      }
    }
  }

  func restorePendingData() {
    // Change the navigationPath after selectedCategory changes.
    if let pendingNavigationPath {
      Logger.archive.log("pending restore")
      navigationPath = pendingNavigationPath
      self.pendingNavigationPath = nil
    }
  }

  func navigate(to path: ArchivePath) {
    guard path != navigationPath.last else {
      Logger.archive.log("already presented: \(path.formatted(), privacy: .public)")
      return
    }
    Logger.archive.log("nav to path: \(path.formatted(), privacy: .public)")
    navigationPath.append(path)
  }

  func navigate(to category: ArchiveCategory?) {
    Logger.archive.log("nav to category: \(category?.rawValue ?? "nil", privacy: .public)")
    selectedCategory = category
  }
}
