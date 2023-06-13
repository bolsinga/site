//
//  ArchiveStorageModifier.swift
//
//
//  Created by Greg Bolsinga on 6/11/23.
//

import SwiftUI

struct ArchiveStorageModifier: ViewModifier {
  let archiveNavigation: ArchiveNavigation

  @SceneStorage("selected.category") private var selectedCategoryData: Data?
  @SceneStorage("navigation.path") private var navigationPathData: Data?

  func body(content: Content) -> some View {
    content
      .task {
        archiveNavigation.restoreNavigation(
          selectionData: selectedCategoryData, pathData: navigationPathData)
      }
      .onChange(of: archiveNavigation.selectedCategory) { newValue in
        selectedCategoryData = newValue?.jsonData

        archiveNavigation.restorePendingData()
      }
      .onChange(of: archiveNavigation.navigationPath) { newPath in
        navigationPathData = newPath.jsonData
      }
  }
}

extension View {
  func archiveStorage(archiveNavigation: ArchiveNavigation) -> some View {
    modifier(ArchiveStorageModifier(archiveNavigation: archiveNavigation))
  }
}
