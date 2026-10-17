//
//  SiteModel+Widget.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

#if !os(tvOS)
  import Shared
  import WidgetKit
  import os

  extension Logger {
    fileprivate static let widgetSnapshot = Logger(category: "widgetSnapshot")
  }

  extension SiteModel {
    @MainActor
    func publishWidgetSnapshot() {
      Logger.widgetSnapshot.log("start")

      guard let vaultModel else {
        Logger.widgetSnapshot.log("no vaultModel, skipping")
        return
      }

      guard let snapshot = try? vaultModel.vault.showsTodaySnapshot else {
        Logger.widgetSnapshot.error("failed to build snapshot")
        return
      }

      Logger.widgetSnapshot.log(
        "built snapshot: days: \(snapshot.days.count, privacy: .public), generated: \(snapshot.generated, privacy: .public)"
      )

      guard let wrote = try? snapshot.write() else {
        Logger.widgetSnapshot.error("failed to write snapshot")
        return
      }

      guard wrote else {
        Logger.widgetSnapshot.log("snapshot unchanged, not reloading timelines")
        return
      }

      Logger.widgetSnapshot.log("wrote snapshot, reloading timelines")
      WidgetCenter.shared.reloadTimelines(ofKind: ShowsTodayWidgetKind.kind)
    }
  }
#endif
