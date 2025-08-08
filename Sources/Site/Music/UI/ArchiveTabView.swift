//
//  ArchiveTabView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

extension ArchiveCategory {
  @MainActor
  fileprivate func badge(_ model: VaultModel) -> Text? {
    let count = model.todayConcerts.count
    guard count > 0 else { return nil }
    switch self {
    case .today:
      return Text(String(count))
    case .shows:
      if combineTodayAndShowSummary {
        return Text(String(count))
      } else {
        return nil
      }
    case .stats, .venues, .artists, .settings, .search:
      return nil
    }
  }
}

private enum ArchiveTab: CaseIterable {
  case today
  case shows
  case venues
  case artists
  case stats
  case settings

  static var `default`: Self { ArchiveCategory.defaultCategory.tab }

  @MainActor
  static var ordered: [ArchiveTab] {
    allCases.filter {
      if case .today = $0 { return !combineTodayAndShowSummary }
      if case .settings = $0 { return showSettingsInTabView }
      return true
    }
  }

  var category: ArchiveCategory {
    switch self {
    case .today:
      .today
    case .shows:
      .shows
    case .venues:
      .venues
    case .artists:
      .artists
    case .stats:
      .stats
    case .settings:
      .settings
    }
  }
}

extension ArchiveCategory {
  fileprivate var tab: ArchiveTab {
    switch self {
    case .today:
      .today
    case .stats:
      .stats
    case .shows:
      .shows
    case .venues:
      .venues
    case .artists:
      .artists
    case .settings:
      .settings
    case .search:
      .settings  // TODO: Add the search tab.
    }
  }
}

struct ArchiveTabView: View {
  @Environment(VaultModel.self) var model

  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  @Binding var selectedCategory: ArchiveCategory
  let pathForCategory: (ArchiveCategory) -> Binding<[ArchivePath]>
  let reloadModel: @MainActor () async -> Void

  @State private var selectedTab = ArchiveTab.default
  @State private var showsMode = ShowsMode.default

  var body: some View {
    TabView(selection: $selectedTab) {
      ForEach(ArchiveTab.ordered, id: \.self) { tab in
        let category = tab.category
        Tab(category.localizedString, systemImage: category.systemImage, value: tab) {
          ArchiveCategoryStack(
            category: category, showsMode: $showsMode, path: pathForCategory(category),
            venueSort: $venueSort,
            artistSort: $artistSort, reloadModel: reloadModel)
        }
        #if !os(tvOS)
          .badge(category.badge(model))
        #endif
      }
    }
    .onAppear {
      selectedTab = selectedCategory.tab
      switch selectedCategory {
      case .today:
        showsMode = .ordinal
      case .shows:
        showsMode = .grouped
      case .stats, .venues, .artists, .settings, .search:
        break
      }
    }
    .onChange(of: selectedTab) { _, newValue in
      selectedCategory = {
        switch newValue {
        case .today:
          .today
        case .shows:
          if combineTodayAndShowSummary {
            switch showsMode {
            case .ordinal:
              .today
            case .grouped:
              .shows
            }
          } else {
            .shows
          }
        case .venues:
          .venues
        case .artists:
          .artists
        case .stats:
          .stats
        case .settings:
          .settings
        }
      }()
    }
    .onChange(of: showsMode) { _, newValue in
      switch newValue {
      case .ordinal:
        selectedCategory = .today
      case .grouped:
        selectedCategory = .shows
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
