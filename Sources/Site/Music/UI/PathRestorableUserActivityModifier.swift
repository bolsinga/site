//
//  PathRestorableUserActivityModifier.swift
//
//
//  Created by Greg Bolsinga on 6/21/23.
//

import SwiftUI
import os

extension ArchivePath {
  static let activityType = "gdb.SiteApp.view-archivePath"
}

extension Logger {
  fileprivate static let pathActivity = Logger(category: "pathActivity")
}

protocol PathRestorableUserActivity: PathRestorable {
  var url: URL? { get }
  func updateActivity(_ userActivity: NSUserActivity)
}

struct PathRestorableUserActivityModifier<T: PathRestorableUserActivity>: ViewModifier {
  let item: T
  let isPathActive: (T) -> Bool

  func body(content: Content) -> some View {
    let isActive = isPathActive(item)
    Logger.pathActivity.log(
      "\(item.archivePath.formatted(.json), privacy: .public) active: \(isActive, privacy: .public)"
    )
    return
      content
      .userActivity(ArchivePath.activityType, isActive: isActive) { userActivity in
        userActivity.update(item)
      }
  }
}

extension View {
  func pathRestorableUserActivityModifier<T: PathRestorableUserActivity>(
    _ item: T, isPathActive: @escaping ((PathRestorable) -> Bool)
  ) -> some View {
    modifier(PathRestorableUserActivityModifier(item: item, isPathActive: isPathActive))
  }
}
