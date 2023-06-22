//
//  PathRestorableUserActivityModifier.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import SwiftUI
import os

extension Logger {
  static let userActivity = Logger(
    subsystem: Bundle.main.bundleIdentifier!, category: "userActivity")
}

extension ArchivePath {
  static let activityType = "gdb.SiteApp.view-archivePath"
}

protocol PathRestorableUserActivity: PathRestorable {
  func updateActivity(_ userActivity: NSUserActivity)
}

struct PathRestorableUserActivityModifier<T: PathRestorableUserActivity>: ViewModifier {
  @Environment(\.vault) var vault: Vault

  let item: T

  func body(content: Content) -> some View {
    content
      .userActivity(ArchivePath.activityType) { userActivity in
        let archivePath = item.archivePath

        let identifier = archivePath.formatted()
        Logger.userActivity.log("advertise: \(identifier, privacy: .public)")
        userActivity.targetContentIdentifier = identifier

        if let url = vault.createURL(for: archivePath) {
          Logger.userActivity.log("web: \(url.absoluteString, privacy: .public)")
          userActivity.isEligibleForPublicIndexing = true
          userActivity.webpageURL = url
        }

        item.updateActivity(userActivity)

        do {
          try userActivity.setTypedPayload(archivePath)
        } catch {
          Logger.userActivity.log("error: \(error, privacy: .public)")
        }
      }
  }

}

extension View {
  func pathRestorableUserActivityModifier<T: PathRestorableUserActivity>(_ item: T) -> some View {
    modifier(PathRestorableUserActivityModifier(item: item))
  }
}
