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

protocol PathRestorableUserActivity: PathRestorable {
  func updateActivity(_ userActivity: NSUserActivity)
}

struct PathRestorableUserActivityModifier<T: PathRestorableUserActivity>: ViewModifier {
  let item: T
  let url: URL?
  let isPathActive: (PathRestorable) -> Bool

  func body(content: Content) -> some View {
    content
      .userActivity(ArchivePath.activityType, isActive: isPathActive(item)) { userActivity in
        userActivity.update(item, url: url)
      }
  }
}

extension View {
  func pathRestorableUserActivityModifier<T: PathRestorableUserActivity>(
    _ item: T, url: URL?, isPathActive: @escaping ((PathRestorable) -> Bool)
  )
    -> some View
  {
    modifier(PathRestorableUserActivityModifier(item: item, url: url, isPathActive: isPathActive))
  }
}
