//
//  ArchiveTabView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import Shared
import SwiftUI

extension ArchiveCategory {
  @MainActor
  fileprivate func badge(_ model: VaultModel) -> Text? {
    let count = model.concerts(on: model.todayDayOfLeapYear).count
    guard count > 0 else { return nil }
    switch self {
    case .today:
      return Text(String(count))
    case .shows, .venues, .artists, .settings, .search:
      return nil
    }
  }

  @MainActor
  static var ordered: [ArchiveCategory] {
    allCases.filter {
      if case .settings = $0 { return showSettingsInTabView }
      return true
    }
  }
}

struct ArchiveTabView: View {
  @Environment(VaultModel.self) var model

  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  @Binding var venuesMode: VenuesMode
  @Binding var showsDescending: Bool

  @Binding var activeCategory: ArchiveCategory
  let pathForCategory: (ArchiveCategory) -> Binding<[ArchivePath]>
  let reloadModel: @MainActor () async -> Void
  let navigateToPath: (ArchivePath) -> Void

  @State private var searchString: String = ""
  @State private var scope: ArchiveScope = .all
  @State private var dayOfLeapYear = Date.now.dayOfLeapYear
  @State private var selectedTab: TabSelection

  init(
    venueSort: Binding<RankingSort>,
    artistSort: Binding<RankingSort>,
    venuesMode: Binding<VenuesMode>,
    showsDescending: Binding<Bool>,
    activeCategory: Binding<ArchiveCategory>,
    pathForCategory: @escaping (ArchiveCategory) -> Binding<[ArchivePath]>,
    reloadModel: @escaping @MainActor () async -> Void,
    navigateToPath: @escaping (ArchivePath) -> Void
  ) {
    self._venueSort = venueSort
    self._artistSort = artistSort
    self._venuesMode = venuesMode
    self._showsDescending = showsDescending
    self._activeCategory = activeCategory
    self.pathForCategory = pathForCategory
    self.reloadModel = reloadModel
    self.navigateToPath = navigateToPath
    // Start on the restored category. Assigning it in onAppear instead echoes back through
    // onChange(of: selectedTab) a frame later, overwriting a deep link handled on cold launch.
    self.selectedTab = TabSelection(
      category: activeCategory.wrappedValue, dayOfLeapYear: Date.now.dayOfLeapYear)
  }

  private func tabValue(for category: ArchiveCategory) -> TabSelection {
    TabSelection(category: category, dayOfLeapYear: model.todayDayOfLeapYear)
  }

  @ViewBuilder private var searchTabContent: some View {
    NavigationStack {
      ArchiveCrossSearchContainer(
        searchString: $searchString, scope: $scope, navigateToPath: navigateToPath,
        artistSearch: model.artists(filteredBy:),
        venueSearch: model.venues(filteredBy:)
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
          Tab(
            category.localizedString, systemImage: category.systemImage,
            value: tabValue(for: category)
          ) {
            ArchiveCategoryStack(
              category: category,
              path: pathForCategory(category),
              venueSort: $venueSort,
              artistSort: $artistSort,
              venuesMode: $venuesMode,
              showsDescending: $showsDescending,
              dayOfLeapYear: $dayOfLeapYear,
              reloadModel: reloadModel,
              navigateToPath: navigateToPath)
          }
          #if !os(tvOS)
            .badge(category.badge(model))
          #endif
        } else {
          #if os(macOS)
            Tab(
              category.localizedString, systemImage: category.systemImage,
              value: tabValue(for: category)
            ) {
              searchTabContent
            }
          #else
            Tab(value: tabValue(for: category), role: .search) { searchTabContent }
          #endif
        }
      }

    }
    .onAppear {
      dayOfLeapYear = model.todayDayOfLeapYear
    }
    .onChange(of: model.todayDayOfLeapYear) { _, newValue in
      dayOfLeapYear = newValue
    }
    .onChange(of: dayOfLeapYear) { _, newValue in
      if selectedTab.category.tracksDayOfLeapYear {
        selectedTab = TabSelection(category: selectedTab.category, dayOfLeapYear: newValue)
      }
    }
    .onChange(of: selectedTab) { _, newValue in
      if let newDayOfLeapYear = newValue.dayOfLeapYear {
        dayOfLeapYear = newDayOfLeapYear
      }
      activeCategory = newValue.category
    }
    .onChange(of: activeCategory) { _, newValue in
      selectedTab = TabSelection(category: newValue, dayOfLeapYear: dayOfLeapYear)
    }
    .tabViewStyle(.sidebarAdaptable)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  @Previewable @State var venueSort = RankingSort.alphabetical
  @Previewable @State var artistSort = RankingSort.alphabetical
  @Previewable @State var category = ArchiveCategory.defaultCategory
  @Previewable @State var venuesMode = VenuesMode.default
  @Previewable @State var showsDescending = false

  ArchiveTabView(
    venueSort: $venueSort,
    artistSort: $artistSort,
    venuesMode: $venuesMode,
    showsDescending: $showsDescending,
    activeCategory: $category
  ) { _ in
    .constant([])
  } reloadModel: {
  } navigateToPath: { _ in
  }
}
