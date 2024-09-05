//
//  ArchiveStateView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI
import os

extension Logger {
  nonisolated(unsafe) static let link = Logger(category: "link")
  #if swift(>=6.0)
    #warning("nonisolated(unsafe) unneeded.")
  #endif
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
      archiveNavigation: archiveNavigation, nearbyModel: nearbyModel)
  }

  var body: some View {
    archiveBody
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

#Preview {
  ArchiveStateView(model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
