//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import SwiftUI

struct ArchiveCategorySplit: View {
  let vault: Vault

  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical

  @State private var todayShows: [Show] = []

  @State private var selectedCategory: ArchiveCategory? = nil
  @SceneStorage("selected.category") private var selectedCategoryData: Data?

  @State private var navigationPath: [ArchivePath] = []
  @SceneStorage("navigation.path") private var navigationPathData: Data?
  @State private var pendingNavigationPath: [ArchivePath]?

  private var music: Music {
    vault.music
  }

  @ViewBuilder var sidebar: some View {
    List(ArchiveCategory.allCases, id: \.self, selection: $selectedCategory) { category in
      LabeledContent {
        switch category {
        case .today:
          Text(todayShows.count.formatted(.number))
            .animation(.easeInOut)
        case .stats:
          EmptyView()
        case .shows:
          Text(music.shows.count.formatted(.number))
        case .venues:
          Text(music.venues.count.formatted(.number))
        case .artists:
          Text(music.artists.count.formatted(.number))
        }
      } label: {
        category.label
      }
    }
  }

  var body: some View {
    NavigationSplitView {
      sidebar
        .navigationTitle(
          Text("Archives", bundle: .module, comment: "Title for the ArchiveCategorySplit."))
    } detail: {
      NavigationStack(path: $navigationPath) {
        ArchiveCategoryDetail(
          category: selectedCategory, todayShows: $todayShows, venueSort: $venueSort,
          artistSort: $artistSort)
      }
    }
    .environment(\.vault, vault)
    .onDayChanged {
      self.todayShows = vault.music.showsOnDate(Date.now).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
    }
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
