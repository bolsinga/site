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
  @Environment(\.vault) var vault: Vault

  let item: T

  func body(content: Content) -> some View {
    content
      .userActivity(ArchivePath.activityType) { userActivity in
        do {
          try userActivity.update(item, url: vault.createURL(for: item.archivePath))
        } catch {
          Logger.updateActivity.log("error: \(error, privacy: .public)")
        }
      }
  }
}

extension View {
  func pathRestorableUserActivityModifier<T: PathRestorableUserActivity>(_ item: T) -> some View {
    modifier(PathRestorableUserActivityModifier(item: item))
  }
}
