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
    /// Building, encoding, and comparing the snapshot scales with the archive, so it runs off the
    /// main actor.
    func publishWidgetSnapshot(_ vault: Vault<BasicIdentifier>) {
      Task.detached(priority: .utility) {
        Logger.widgetSnapshot.log("start")

        guard let snapshot = try? vault.showsTodaySnapshot else {
          Logger.widgetSnapshot.error("failed to build snapshot")
          return
        }

        guard let wrote = try? snapshot.write() else {
          Logger.widgetSnapshot.error("failed to write snapshot")
          return
        }

        guard wrote else {
          Logger.widgetSnapshot.log("snapshot unchanged, not reloading timelines")
          return
        }

        Logger.widgetSnapshot.log("wrote snapshot, reloading timelines")
        await MainActor.run {
          WidgetCenter.shared.reloadTimelines(ofKind: ShowsTodayWidgetKind.kind)
        }
      }
    }
  }
#endif
