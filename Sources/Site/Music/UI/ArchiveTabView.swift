//
//  ArchiveTabView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

#if canImport(UIKit)
  import UIKit

  extension UIDevice {
    fileprivate var showSettingsInTabView: Bool {
      // Ideally this could check if the TabView was able to show a sidebar.
      userInterfaceIdiom != .phone
    }
  }

  @MainActor
  private var showSettingsInTabView: Bool {
    UIDevice.current.showSettingsInTabView
  }
#else
  private let showSettingsInTabView = false
#endif

extension ArchiveCategory {
  fileprivate func badge(_ model: VaultModel) -> Text? {
    let count = model.todayConcerts.count
    guard count > 0 else { return nil }
    switch self {
    case .today:
      return Text(String(count))
    case .stats, .shows, .venues, .artists, .settings:
      return nil
    }
  }

  @MainActor
  fileprivate static var trailingTabs: [ArchiveCategory] {
    if showSettingsInTabView {
      [.stats, .settings]
    } else {
      [.stats]
    }
  }

  @MainActor
  fileprivate static var tagOrder: [ArchiveCategory] {
    allCases.filter {
      if case .stats = $0 { return false }
      if case .settings = $0 { return false }
      return true
    } + trailingTabs
  }
}

struct ArchiveTabView: View {
  @Environment(VaultModel.self) var model

  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  @Binding var selectedCategory: ArchiveCategory
  let pathForCategory: (ArchiveCategory) -> Binding<[ArchivePath]>
  let reloadModel: @MainActor () async -> Void

  var body: some View {
    TabView(selection: $selectedCategory) {
      ForEach(ArchiveCategory.tagOrder, id: \.self) { category in
        Tab(category.localizedString, systemImage: category.systemImage, value: category) {
          ArchiveCategoryStack(
            category: category, path: pathForCategory(category), venueSort: $venueSort,
            artistSort: $artistSort, reloadModel: reloadModel)
        }
        #if !os(tvOS)
          .badge(category.badge(model))
        #endif
      }
    }
    .tabViewStyle(.sidebarAdaptable)
  }
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveTabView(
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    selectedCategory: .constant(.today), pathForCategory: { _ in .constant([]) }
  ) {}
}
