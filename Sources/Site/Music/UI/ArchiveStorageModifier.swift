//
//  ArchiveStorageModifier.swift
//
//
//  Created by Greg Bolsinga on 6/11/23.
//

import SwiftUI

struct ArchiveStorageModifier: ViewModifier {
  @Binding var selectedCategory: ArchiveCategory?
  @SceneStorage("selected.category") private var selectedCategoryData: Data?

  @Binding var navigationPath: [ArchivePath]
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
          if selectedCategory != nil {
            selectedCategory?.jsonData = data
          } else {
            var category = ArchiveCategory.today
            category.jsonData = data
            selectedCategory = category
          }
        }
      }
      .onChange(of: selectedCategory) { newValue in
        selectedCategoryData = newValue?.jsonData

        // Change the navigationPath after selectedCategory changes.
        if let pendingNavigationPath {
          navigationPath = pendingNavigationPath
          self.pendingNavigationPath = nil
        }
      }
      .onChange(of: navigationPath) { newPath in
        navigationPathData = newPath.jsonData
      }
  }
}

extension View {
  func archiveStorage(
    selectedCategory: Binding<ArchiveCategory?>, navigationPath: Binding<[ArchivePath]>
  ) -> some View {
    modifier(
      ArchiveStorageModifier(selectedCategory: selectedCategory, navigationPath: navigationPath))
  }
}
