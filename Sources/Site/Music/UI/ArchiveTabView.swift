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
  case search

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
    case .search:
      .search
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
      .search
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
  let navigateToPath: (ArchivePath) -> Void

  @State var searchString: String = ""
  @State var scope: ArchiveScope = .all

  @ViewBuilder private var searchTabContent: some View {
    NavigationStack {
      ArchiveCrossSearchContainer(
        searchString: $searchString, scope: $scope, navigateToPath: navigateToPath
      )
      .searchable(
        text: $searchString,
        prompt: String(localized: "Artist or Venue Name", bundle: .module)
      )
      .searchScopes($scope) {
        ForEach(ArchiveScope.allCases, id: \.self) {
          Text($0.localizedString).tag($0)
        }
      }
    }
  }

  @State private var selectedTab = ArchiveTab.default
  @State private var showsMode = ShowsMode.default

  var body: some View {
    TabView(selection: $selectedTab) {
      ForEach(ArchiveTab.ordered, id: \.self) { tab in
        let category = tab.category
        if tab != .search {
          Tab(category.localizedString, systemImage: category.systemImage, value: tab) {
            ArchiveCategoryStack(
              category: category, showsMode: $showsMode, path: pathForCategory(category),
              venueSort: $venueSort,
              artistSort: $artistSort, reloadModel: reloadModel)
          }
          #if !os(tvOS)
            .badge(category.badge(model))
          #endif
        } else {
          #if os(macOS) && swift(<6.2)
            Tab(
              String(localized: "Search", bundle: .module), systemImage: category.systemImage,
              value: tab
            ) { searchTabContent }
          #else
            Tab(value: tab, role: .search) { searchTabContent }
          #endif
        }
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
        case .search:
          .search
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
    .onChange(of: selectedCategory) { _, newValue in
      selectedTab = newValue.tab
    }
    .tabViewStyle(.sidebarAdaptable)
  }
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ArchiveTabView(
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    selectedCategory: .constant(.today)
  ) { _ in
    .constant([])
  } reloadModel: {
  } navigateToPath: { _ in
  }
}
