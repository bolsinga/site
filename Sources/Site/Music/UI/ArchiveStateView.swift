//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI
import os

extension Logger {
  static let link = Logger(category: "link")
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
      selectedCategory: $archiveNavigation.category,
      path: $archiveNavigation.path, nearbyModel: nearbyModel)
  }

  var body: some View {
    archiveBody
      .onContinueUserActivity(ArchivePath.activityType) { userActivity in
        guard let path = userActivity.archivePath else {
          Logger.decodeActivity.error("no path")
          return
        }
        archiveNavigation.navigate(to: path)
      }
      .onContinueUserActivity(ArchiveCategory.activityType) { userActivity in
        guard let category = userActivity.archiveCategory else {
          Logger.decodeActivity.error("no category")
          return
        }
        archiveNavigation.navigate(to: category)
      }
      .onOpenURL { url in
        Logger.link.log("url: \(url.absoluteString, privacy: .public)")
        if let archivePath = try? ArchivePath(url) {
          archiveNavigation.navigate(to: archivePath)
        } else {
          Logger.link.error("url not path")

          if let archiveCategory = try? ArchiveCategory(url) {
            archiveNavigation.navigate(to: archiveCategory)
          } else {
            Logger.link.error("url not category")
          }
        }
      }
  }
}

#Preview {
  ArchiveStateView(model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
