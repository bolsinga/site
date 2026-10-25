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
    /// Builds and writes the widget snapshot off the main actor, one publish at a time: starting a
    /// new one cancels the one before it, and a cancelled publish doesn't write, so an older
    /// snapshot can't land after a newer one.
    /// - Parameters:
    ///   - build: Builds the snapshot. Scales with the archive, so it runs off the main actor.
    ///   - write: Writes the snapshot, returning whether the bytes changed.
    ///   - reload: Asks the widget to reload, only when the bytes changed.
    /// - Returns: The publish, so a caller can wait for it.
    @MainActor
    @discardableResult
    func publishWidgetSnapshot(
      build: @escaping @Sendable () throws -> ShowsTodaySnapshot,
      write: @escaping @Sendable (ShowsTodaySnapshot) throws -> Bool,
      reload: @escaping @MainActor @Sendable () -> Void
    ) -> Task<Void, Never> {
      widgetPublish?.cancel()

      let publish = Task.detached(priority: .utility) {
        Logger.widgetSnapshot.log("start")

        guard let snapshot = try? build() else {
          Logger.widgetSnapshot.error("failed to build snapshot")
          return
        }

        guard !Task.isCancelled else {
          Logger.widgetSnapshot.log("superseded, not writing")
          return
        }

        guard let wrote = try? write(snapshot) else {
          Logger.widgetSnapshot.error("failed to write snapshot")
          return
        }

        guard wrote else {
          Logger.widgetSnapshot.log("snapshot unchanged, not reloading timelines")
          return
        }

        Logger.widgetSnapshot.log("wrote snapshot, reloading timelines")
        await MainActor.run { reload() }
      }
      widgetPublish = publish
      return publish
    }

    @MainActor
    func publishWidgetSnapshot(_ vault: Vault<BasicIdentifier>) {
      publishWidgetSnapshot(
        build: { try vault.showsTodaySnapshot },
        write: { try $0.write() },
        reload: { WidgetCenter.shared.reloadTimelines(ofKind: ShowsTodayWidgetKind.kind) })
    }
  }
#endif
