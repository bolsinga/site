//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import SwiftUI
import os

extension Logger {
  static let today = Logger(category: "today")
  static let link = Logger(category: "link")
}

struct ArchiveCategorySplit: View {
  let vault: Vault

  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical

  @State private var todayShows: [Show] = []

  @StateObject private var archiveNavigation = ArchiveNavigation()

  private var music: Music {
    vault.music
  }

  @ViewBuilder var sidebar: some View {
    List(ArchiveCategory.allCases, id: \.self, selection: $archiveNavigation.selectedCategory) {
      category in
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
      NavigationStack(path: $archiveNavigation.navigationPath) {
        ArchiveCategoryDetail(
          category: archiveNavigation.selectedCategory, todayShows: $todayShows,
          venueSort: $venueSort,
          artistSort: $artistSort)
      }
    }
    .archiveStorage(archiveNavigation: archiveNavigation)
    .environment(\.vault, vault)
    .onDayChanged {
      self.todayShows = vault.music.showsOnDate(Date.now).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
      Logger.today.log("Count: \(todayShows.count, privacy: .public)")
    }
    .onContinueUserActivity(ArchivePath.activityType) { userActivity in
      do {
        archiveNavigation.navigate(to: try userActivity.archivePath())
      } catch {
        Logger.decodeActivity.log("error: \(error, privacy: .public)")
      }
    }
    .onOpenURL { url in
      Logger.link.log("url: \(url.absoluteString, privacy: .public)")
      do {
        let archivePath = try ArchivePath(url)
        archiveNavigation.navigate(to: archivePath)
      } catch {
        Logger.link.log("error: \(error, privacy: .public)")
      }
    }
    .refreshable {
      self.todayShows = vault.music.showsOnDate(Date.now).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
      Logger.today.log("refreshed count: \(todayShows.count, privacy: .public)")
    }
  }
}
