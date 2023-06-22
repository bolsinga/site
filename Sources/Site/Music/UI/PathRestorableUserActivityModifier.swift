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
  let item: T

  func body(content: Content) -> some View {
    content
      .userActivity(ArchivePath.activityType) { userActivity in
        let identifier = item.archivePath.formatted()
        Logger.userActivity.log("advertise: \(identifier, privacy: .public)")
        userActivity.targetContentIdentifier = identifier
        item.updateActivity(userActivity)
      }
  }

}

extension View {
  func pathRestorableUserActivityModifier<T: PathRestorableUserActivity>(_ item: T) -> some View {
    modifier(PathRestorableUserActivityModifier(item: item))
  }
}
