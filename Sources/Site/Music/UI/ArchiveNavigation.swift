//
//  ArchiveNavigation.swift
//
//
//  Created by Greg Bolsinga on 6/13/23.
//

import Foundation
import os

@Observable final class ArchiveNavigation {
  var selectedCategory: ArchiveCategory?
  var navigationPath: [ArchivePath] = []

  @ObservationIgnored internal var pendingNavigationPath: [ArchivePath]?

  private let archive = Logger(category: "archive")

  func restoreNavigation(selectedCategoryStorage: ArchiveCategory?, pathData: Data?) {
    if let selectedCategoryStorage {
      if let pathData {
        // Hold onto the loading navigationPath for after the selectedCategory changes.
        var pending = [ArchivePath]()
        pending.jsonData = pathData
        archive.log(
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
      archive.log("pending restore")
      navigationPath = pendingNavigationPath
      self.pendingNavigationPath = nil
    }
  }

  func navigate(to path: ArchivePath) {
    guard path != navigationPath.last else {
      archive.log("already presented: \(path.formatted(), privacy: .public)")
      return
    }
    archive.log("nav to path: \(path.formatted(), privacy: .public)")
    navigationPath.append(path)
  }

  func navigate(to category: ArchiveCategory?) {
    archive.log("nav to category: \(category?.rawValue ?? "nil", privacy: .public)")
    selectedCategory = category
  }
}
