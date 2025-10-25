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
    let count = model.concerts(on: model.todayDayOfLeapYear).count
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

  @MainActor
  static var ordered: [ArchiveCategory] {
    allCases.filter {
      if case .today = $0 { return !combineTodayAndShowSummary }
      if case .settings = $0 { return showSettingsInTabView }
      return true
    }
  }
}

struct ArchiveTabView: View {
  @Environment(VaultModel.self) var model

  @Binding var showsMode: ShowsMode
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort

  @Binding var activeCategory: ArchiveCategory
  let pathForCategory: (ArchiveCategory) -> Binding<[ArchivePath]>
  let reloadModel: @MainActor () async -> Void
  let navigateToPath: (ArchivePath) -> Void

  @State private var searchString: String = ""
  @State private var scope: ArchiveScope = .all
  @State private var selectedTab = ArchiveCategory.defaultCategory

  @ViewBuilder private var searchTabContent: some View {
    NavigationStack {
      ArchiveCrossSearchContainer(
        searchString: $searchString, scope: $scope, navigateToPath: navigateToPath
      )
      .searchable(
        text: $searchString,
        prompt: String(localized: "Artist or Venue Name")
      )
      .searchScopes($scope) {
        ForEach(ArchiveScope.allCases, id: \.self) {
          Text($0.localizedString).tag($0)
        }
      }
      .navigationTitle(Text(ArchiveCategory.search.localizedString))
    }
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      ForEach(ArchiveCategory.ordered, id: \.self) { category in
        if category != .search {
          Tab(category.localizedString, systemImage: category.systemImage, value: category) {
            ArchiveCategoryStack(
              category: category, showsMode: $showsMode, path: pathForCategory(category),
              venueSort: $venueSort,
              artistSort: $artistSort, reloadModel: reloadModel)
          }
          #if !os(tvOS)
            .badge(category.badge(model))
          #endif
        } else {
          #if os(macOS)
            Tab(category.localizedString, systemImage: category.systemImage, value: category) {
              searchTabContent
            }
          #else
            Tab(value: category, role: .search) { searchTabContent }
          #endif
        }
      }

    }
    .onAppear {
      selectedTab = activeCategory
    }
    .onChange(of: selectedTab) { _, newValue in
      activeCategory = {
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
    .onChange(of: activeCategory) { _, newValue in
      selectedTab = newValue
    }
    .tabViewStyle(.sidebarAdaptable)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  @Previewable @State var showsMode = ShowsMode.grouped
  @Previewable @State var venueSort = RankingSort.alphabetical
  @Previewable @State var artistSort = RankingSort.alphabetical
  @Previewable @State var category = ArchiveCategory.defaultCategory

  ArchiveTabView(
    showsMode: $showsMode, venueSort: $venueSort, artistSort: $artistSort, activeCategory: $category
  ) { _ in
    .constant([])
  } reloadModel: {
  } navigateToPath: { _ in
  }
}
