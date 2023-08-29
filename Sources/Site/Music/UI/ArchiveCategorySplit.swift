//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import SwiftUI
import os

extension Logger {
  static let link = Logger(category: "link")
}

struct ArchiveCategorySplit: View {
  let vault: Vault
  @ObservedObject var model: VaultModel

  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical

  @StateObject private var archiveNavigation = ArchiveNavigation()

  @ViewBuilder var sidebar: some View {
    List(ArchiveCategory.allCases, id: \.self, selection: $archiveNavigation.selectedCategory) {
      category in
      LabeledContent {
        switch category {
        case .today:
          Text(model.todayConcerts.count.formatted(.number))
            .animation(.easeInOut)
        case .stats:
          EmptyView()
        case .shows:
          Text(vault.shows.count.formatted(.number))
        case .venues:
          Text(vault.venues.count.formatted(.number))
        case .artists:
          Text(vault.artists.count.formatted(.number))
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
          category: archiveNavigation.selectedCategory, todayConcerts: $model.todayConcerts,
          venueSort: $venueSort, artistSort: $artistSort,
          isCategoryActive: .constant(archiveNavigation.navigationPath.isEmpty))
      }
    }
    .archiveStorage(archiveNavigation: archiveNavigation)
    .environment(\.vault, vault)
    .onContinueUserActivity(ArchivePath.activityType) { userActivity in
      do {
        archiveNavigation.navigate(to: try userActivity.archivePath())
      } catch {
        Logger.decodeActivity.log("error: \(error, privacy: .public)")
      }
    }
    .onContinueUserActivity(ArchiveCategory.activityType) { userActivity in
      do {
        archiveNavigation.navigate(to: try userActivity.archiveCategory())
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
        Logger.link.log("ArchivePath to URL error: \(error, privacy: .public)")

        do {
          let archiveCategory = try ArchiveCategory(url)
          archiveNavigation.navigate(to: archiveCategory)
        } catch {
          Logger.link.log("ArchiveCategory to URL error: \(error, privacy: .public)")
        }
      }
    }
  }
}
