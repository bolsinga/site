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

  private var geocodingProgress: Double {
    Double(model.geocodedVenuesCount) / Double(vault.venueDigests.count)
  }

  @ViewBuilder private var nearbyLabel: some View {
    switch model.locationAuthorization {
    case .allowed:
      NearbyLabel(
        nearbyConcertCount: .constant(model.nearbyConcerts.count),
        geocodingProgress: .constant(geocodingProgress))
    case .restricted:
      Text(
        "Location Disabled", bundle: .module,
        comment: "Text shown when location services are restrictued by user.")
    case .denied:
      Text(
        "Location Unavailable", bundle: .module,
        comment: "Text shown when location services are denied.")
    }
  }

  @ViewBuilder var sidebar: some View {
    List(ArchiveCategory.allCases, id: \.self, selection: $archiveNavigation.selectedCategory) {
      category in
      LabeledContent {
        switch category {
        case .today:
          Text(model.todayConcerts.count.formatted(.number))
            .animation(.easeInOut)
        case .nearby:
          nearbyLabel
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
          todayConcerts: $model.todayConcerts, nearbyConcerts: .constant(model.nearbyConcerts),
          venueSort: $venueSort, artistSort: $artistSort,
          isCategoryActive: .constant(archiveNavigation.navigationPath.isEmpty),
          geocodingProgress: .constant(geocodingProgress))
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
