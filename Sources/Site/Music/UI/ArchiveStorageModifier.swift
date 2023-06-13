//
//  ArchiveStorageModifier.swift
//
//
//  Created by Greg Bolsinga on 6/11/23.
//

import SwiftUI

struct ArchiveStorageModifier: ViewModifier {
  @EnvironmentObject private var archiveNavigation: ArchiveNavigation

  @SceneStorage("selected.category") private var selectedCategoryData: Data?
  @SceneStorage("navigation.path") private var navigationPathData: Data?
  @State private var pendingNavigationPath: [ArchivePath]?

  func body(content: Content) -> some View {
    content
      .task {
        if let data = selectedCategoryData {
          if let data = navigationPathData {
            // Hold onto the loading navigationPath for after the selectedCategory changes.
            var pending = [ArchivePath]()
            pending.jsonData = data
            pendingNavigationPath = pending
          }

          // Changing the selectedCategory will reset the NavigationStack's navigationPath.
          if archiveNavigation.selectedCategory != nil {
            archiveNavigation.selectedCategory?.jsonData = data
          } else {
            var category = ArchiveCategory.today
            category.jsonData = data
            archiveNavigation.selectedCategory = category
          }
        }
      }
      .onChange(of: archiveNavigation.selectedCategory) { newValue in
        selectedCategoryData = newValue?.jsonData

        // Change the navigationPath after selectedCategory changes.
        if let pendingNavigationPath {
          archiveNavigation.navigationPath = pendingNavigationPath
          self.pendingNavigationPath = nil
        }
      }
      .onChange(of: archiveNavigation.navigationPath) { newPath in
        navigationPathData = newPath.jsonData
      }
  }
}

extension View {
  func archiveStorage() -> some View {
    modifier(
      ArchiveStorageModifier())
  }
}
