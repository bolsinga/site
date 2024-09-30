//
//  ArchiveNavigationUserActivityModifier.swift
//  site
//
//  Created by Greg Bolsinga on 9/29/24.
//

import SwiftUI
import os

extension ArchiveCategory {
  static let activityType = "gdb.SiteApp.view-archiveCategory"
}

extension Logger {
  fileprivate static let navigationUserActivity = Logger(category: "navigationUserActivity")
}

struct ArchiveNavigationUserActivityModifier: ViewModifier {
  let archiveNavigation: ArchiveNavigation
  let urlForCategory: (ArchiveCategory) -> URL?

  @State private var userActivityCategory: ArchiveNavigation.State.DefaultCategory =
    ArchiveNavigation.State.defaultCategory

  func body(content: Content) -> some View {
    let isCategoryActive = {
      #if os(iOS) || os(tvOS)
        guard let userActivityCategory else { return false }
      #endif
      return archiveNavigation.userActivityActive(for: userActivityCategory)
    }()

    #if os(iOS) || os(tvOS)
      Logger.navigationUserActivity.log(
        "\(userActivityCategory?.rawValue ?? "nil", privacy: .public) active: \(isCategoryActive, privacy: .public)"
      )
    #elseif os(macOS)
      Logger.navigationUserActivity.log(
        "\(userActivityCategory.rawValue, privacy: .public) active: \(isCategoryActive, privacy: .public)"
      )
    #endif

    return
      content
      .onAppear { userActivityCategory = archiveNavigation.category }
      .onChange(of: archiveNavigation.category) { _, newValue in
        userActivityCategory = newValue
      }
      .userActivity(ArchiveCategory.activityType, isActive: isCategoryActive) { userActivity in
        #if os(iOS) || os(tvOS)
          guard let userActivityCategory else { return }
        #endif
        userActivity.update(userActivityCategory, url: urlForCategory(userActivityCategory))
      }
  }
}

extension View {
  func advertiseUserActivity(
    for archiveNavigation: ArchiveNavigation, urlForCategory: @escaping (ArchiveCategory) -> URL?
  ) -> some View {
    modifier(
      ArchiveNavigationUserActivityModifier(
        archiveNavigation: archiveNavigation, urlForCategory: urlForCategory))
  }
}
