//
//  ArchiveStorageModifier.swift
//
//
//  Created by Greg Bolsinga on 6/11/23.
//

import SwiftUI
import os

extension Logger {
  static let archive = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "archive")
}

struct ArchiveStorageModifier: ViewModifier {
  let archiveNavigation: ArchiveNavigation

  @SceneStorage("selected.category") private var selectedCategoryStorage: ArchiveCategory?
  @SceneStorage("navigation.path") private var navigationPathData: Data?

  func body(content: Content) -> some View {
    content
      .task {
        Logger.archive.log("start restore")
        defer {
          Logger.archive.log("end restore")
        }
        archiveNavigation.restoreNavigation(
          selectedCategoryStorage: selectedCategoryStorage, pathData: navigationPathData)
      }
      .onChange(of: archiveNavigation.selectedCategory) { newValue in
        Logger.archive.log("category: \(newValue?.rawValue ?? "nil", privacy: .public)")
        selectedCategoryStorage = newValue

        archiveNavigation.restorePendingData()
      }
      .onChange(of: archiveNavigation.navigationPath) { newPath in
        Logger.archive.log(
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
