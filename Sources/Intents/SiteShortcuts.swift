//
//  SiteShortcuts.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

import AppIntents
import Foundation

class SiteShortcuts: AppShortcutsProvider {
  static let shortcutTileColor = ShortcutTileColor.grayGreen

  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: OpenCategory(),
      phrases: [
        "Open \(\.$target) in \(.applicationName)",
        "Show \(\.$target) in \(.applicationName)",
      ],
      shortTitle: "Open Category", systemImageName: "building.columns")
  }
}
