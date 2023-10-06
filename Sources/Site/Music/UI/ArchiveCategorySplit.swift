//
//  ArchiveCategorySplit.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import CoreLocation
import SwiftUI
import os

extension Logger {
  static let link = Logger(category: "link")
}

struct ArchiveCategorySplit: View {
  let vault: Vault
  @ObservedObject var model: VaultModel

  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("venue.filter") private var venueLocationFilter = LocationFilter.none
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical
  @SceneStorage("nearby.distance") private var nearbyDistanceThreshold: CLLocationDistance =
    16093.44  // 10 miles
  @SceneStorage("show.filter") private var showLocationFilter = LocationFilter.none

  @StateObject private var archiveNavigation = ArchiveNavigation()

  private var geocodingProgress: Double {
    Double(model.geocodedVenuesCount) / Double(vault.venueDigests.count)
  }

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
          Text("Archives", bundle: .module, comment: "Title for the ArchiveCategorySplit."))
    } detail: {
      NavigationStack(path: $archiveNavigation.navigationPath) {
        ArchiveCategoryDetail(
          vault: vault, category: archiveNavigation.selectedCategory,
          todayConcerts: $model.todayConcerts,
          nearbyConcerts: .constant(model.concertsNearby(nearbyDistanceThreshold)),
          venueSort: $venueSort, venueLocationFilter: $venueLocationFilter, artistSort: $artistSort,
          isCategoryActive: .constant(archiveNavigation.navigationPath.isEmpty),
          geocodingProgress: .constant(geocodingProgress), showLocationFilter: $showLocationFilter,
          locationAuthorization: $model.locationAuthorization)
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
      do {
        archiveNavigation.navigate(to: try userActivity.archiveCategory())
      } catch {
        Logger.decodeActivity.error("error: \(error, privacy: .public)")
      }
    }
    .onOpenURL { url in
      Logger.link.log("url: \(url.absoluteString, privacy: .public)")
      do {
        let archivePath = try ArchivePath(url)
        archiveNavigation.navigate(to: archivePath)
      } catch {
        Logger.link.error("ArchivePath to URL error: \(error, privacy: .public)")

        do {
          let archiveCategory = try ArchiveCategory(url)
          archiveNavigation.navigate(to: archiveCategory)
        } catch {
          Logger.link.error("ArchiveCategory to URL error: \(error, privacy: .public)")
        }
      }
    }
  }
}
