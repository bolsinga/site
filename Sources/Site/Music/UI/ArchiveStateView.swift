//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI
import os

extension Logger {
  fileprivate static let externalEvent = Logger(category: "externalEvent")
}

struct ArchiveStateView: View {
  let model: VaultModel

  @SceneStorage("venue.sort") private var venueSort = RankingSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = RankingSort.alphabetical
  @SceneStorage("navigation.state") private var archiveNavigation = ArchiveNavigation()

  @State private var nearbyModel: NearbyModel

  internal init(model: VaultModel) {
    self.model = model
    self.nearbyModel = NearbyModel(vaultModel: model)
  }

  @ViewBuilder private var archiveBody: some View {
    ArchiveCategorySplit(
      model: model, venueSort: $venueSort, artistSort: $artistSort,
      selectedCategory: $archiveNavigation.category, path: $archiveNavigation.path,
      nearbyModel: nearbyModel, isCategoryActive: archiveNavigation.userActivityActive(for:))
  }

  var body: some View {
    archiveBody
      .onContinueUserActivity(ArchivePath.activityType) { userActivity in
        Logger.externalEvent.log(
          "onContinueUserActivity: \(ArchivePath.activityType, privacy: .public)")

        guard let path = userActivity.archivePath else {
          Logger.externalEvent.error("no path")
          return
        }
        archiveNavigation.navigate(to: path)
      }
      .onContinueUserActivity(ArchiveCategory.activityType) { userActivity in
        Logger.externalEvent.log(
          "onContinueUserActivity: \(ArchiveCategory.activityType, privacy: .public)")

        guard let category = userActivity.archiveCategory else {
          Logger.externalEvent.error("no category")
          return
        }
        archiveNavigation.navigate(to: category)
      }
      .onOpenURL { url in
        Logger.externalEvent.log("onOpenURL: \(url.absoluteString, privacy: .public)")
        if let archivePath = try? ArchivePath(url) {
          archiveNavigation.navigate(to: archivePath)
        } else {
          Logger.externalEvent.error("url not path")

          if let archiveCategory = try? ArchiveCategory(url) {
            archiveNavigation.navigate(to: archiveCategory)
          } else {
            Logger.externalEvent.error("url not category")
          }
        }
      }
      .advertiseUserActivity(
        for: archiveNavigation, urlForCategory: { model.vault.categoryURLMap[$0] })
  }
}

#Preview {
  ArchiveStateView(model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
