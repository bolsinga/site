//
//  ArchiveNavigation.swift
//
//
//  Created by Greg Bolsinga on 6/13/23.
//

import Combine
import Foundation

final class ArchiveNavigation: ObservableObject {
  @Published var selectedCategory: ArchiveCategory?
  @Published var navigationPath: [ArchivePath] = []

  private var pendingNavigationPath: [ArchivePath]?

  func restoreNavigation(selectionData: Data?, pathData: Data?) {
    if let data = selectionData {
      if let data = pathData {
        // Hold onto the loading navigationPath for after the selectedCategory changes.
        var pending = [ArchivePath]()
        pending.jsonData = data
        pendingNavigationPath = pending
      }

      // Changing the selectedCategory will reset the NavigationStack's navigationPath.
      if selectedCategory != nil {
        selectedCategory?.jsonData = data
      } else {
        var category = ArchiveCategory.today
        category.jsonData = data
        selectedCategory = category
      }
    }
  }

  func restorePendingData() {
    // Change the navigationPath after selectedCategory changes.
    if let pendingNavigationPath {
      navigationPath = pendingNavigationPath
      self.pendingNavigationPath = nil
    }
  }
}
