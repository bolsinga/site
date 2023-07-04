//
//  ArchiveStorageModifier.swift
//
//
//  Created by Greg Bolsinga on 6/11/23.
//

import SwiftUI
import os

extension Logger {
  static let storage = Logger(category: "storage")
}

struct ArchiveStorageModifier: ViewModifier {
  let archiveNavigation: ArchiveNavigation

  @SceneStorage("selected.category") private var selectedCategoryStorage: String?
  @SceneStorage("navigation.path") private var navigationPathData: Data?

  func body(content: Content) -> some View {
    content
      .task {
        Logger.storage.log("start restore")
        defer {
          Logger.storage.log("end restore")
        }
        let archiveCategory =
          selectedCategoryStorage != nil ? ArchiveCategory(rawValue: selectedCategoryStorage!) : nil
        archiveNavigation.restoreNavigation(
          selectedCategoryStorage: archiveCategory, pathData: navigationPathData)
      }
      .onChange(of: archiveNavigation.selectedCategory) { newValue in
        Logger.storage.log("category: \(newValue?.rawValue ?? "nil", privacy: .public)")
        selectedCategoryStorage = newValue?.rawValue ?? nil

        archiveNavigation.restorePendingData()
      }
      .onChange(of: archiveNavigation.navigationPath) { newPath in
        Logger.storage.log(
          "path: \(newPath.map { $0.formatted() }.joined(separator: ":"), privacy: .public)")
        navigationPathData = newPath.jsonData
      }
  }
}

extension View {
  func archiveStorage(archiveNavigation: ArchiveNavigation) -> some View {
    modifier(ArchiveStorageModifier(archiveNavigation: archiveNavigation))
  }
}
