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

  func body(content: Content) -> some View {
    content
      .userActivity(ArchivePath.activityType) { userActivity in
        userActivity.update(item, url: url)
      }
  }
}

extension View {
  func pathRestorableUserActivityModifier<T: PathRestorableUserActivity>(_ item: T, url: URL?)
    -> some View
  {
    modifier(PathRestorableUserActivityModifier(item: item, url: url))
  }
}
