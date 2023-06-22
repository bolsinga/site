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
  static let programmatic = Logger(
    subsystem: Bundle.main.bundleIdentifier!, category: "programmatic")
  static let pending = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "pending")
}

final class ArchiveNavigation: ObservableObject {
  @Published var selectedCategory: ArchiveCategory?
  @Published var navigationPath: [ArchivePath] = []

  private var pendingNavigationPath: [ArchivePath]?

  func restoreNavigation(selectedCategoryStorage: ArchiveCategory?, pathData: Data?) {
    if let selectedCategoryStorage {
      if let pathData {
        // Hold onto the loading navigationPath for after the selectedCategory changes.
        var pending = [ArchivePath]()
        pending.jsonData = pathData
        Logger.pending.log(
          "saving: \(pending.map { $0.formatted() }.joined(separator: ":"), privacy: .public)")
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
      Logger.pending.log("restore")
      navigationPath = pendingNavigationPath
      self.pendingNavigationPath = nil
    }
  }

  func navigate(to path: ArchivePath) {
    guard path != navigationPath.last else {
      Logger.programmatic.log("already presented: \(path.formatted(), privacy: .public)")
      return
    }
    Logger.programmatic.log("nav to path: \(path.formatted(), privacy: .public)")
    navigationPath.append(path)
  }

  func navigate(to category: ArchiveCategory) {
    Logger.programmatic.log("nav to category: \(category.rawValue, privacy: .public)")
    selectedCategory = category
  }
}
