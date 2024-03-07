//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import CoreLocation
import SwiftUI
import os

struct ArchiveCategorySplit: View {
  var model: VaultModel

  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical

  @State private var archiveNavigation = ArchiveNavigation()
  @State private var nearbyModel: NearbyModel

  internal init(model: VaultModel) {
    self.model = model
    self.nearbyModel = NearbyModel(vaultModel: model)
  }

  private var vault: Vault { model.vault }

  @MainActor
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
          Text(vault.concerts.count.formatted(.number))
        case .venues:
          Text(vault.venueDigests.count.formatted(.number))
        case .artists:
          Text(vault.artistDigests.count.formatted(.number))
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
          Text("Archives", bundle: .module)
        )
        .nearbyDistanceThreshold(nearbyModel)
    } detail: {
      NavigationStack(path: $archiveNavigation.navigationPath) {
        ArchiveCategoryDetail(
          model: model, category: archiveNavigation.selectedCategory,
          venueSort: $venueSort, artistSort: $artistSort,
          isCategoryActive: archiveNavigation.navigationPath.isEmpty,
          nearbyModel: nearbyModel)
      }
    }
    .archiveStorage(archiveNavigation: archiveNavigation)
    .onContinueUserActivity(ArchivePath.activityType) { userActivity in
      do {
        archiveNavigation.navigate(to: try userActivity.archivePath())
      } catch {
        Logger.decodeActivity.error("error: \(error, privacy: .public)")
      }
    }
    .onContinueUserActivity(ArchiveCategory.activityType) { userActivity in
      let decodeCategoryActivityLogger = Logger(category: "decodeCategoryActivity")
      do {
        archiveNavigation.navigate(
          to: try userActivity.archiveCategory(decodeCategoryActivityLogger))
      } catch {
        decodeCategoryActivityLogger.error("error: \(error, privacy: .public)")
      }
    }
    .onOpenURL { url in
      let link = Logger(category: "link")
      link.log("url: \(url.absoluteString, privacy: .public)")
      do {
        let archivePath = try ArchivePath(url)
        archiveNavigation.navigate(to: archivePath)
      } catch {
        link.error("ArchivePath to URL error: \(error, privacy: .public)")

        do {
          let archiveCategory = try ArchiveCategory(url)
          archiveNavigation.navigate(to: archiveCategory)
        } catch {
          link.error("ArchiveCategory to URL error: \(error, privacy: .public)")
        }
      }
    }
  }
}
