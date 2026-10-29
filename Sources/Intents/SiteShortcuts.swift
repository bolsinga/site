//
//  SiteShortcuts.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

import AppIntents
import Foundation
import Shared

struct SiteShortcuts: AppShortcutsProvider {
  static let shortcutTileColor = ShortcutTileColor.grayGreen

  // AppShortcut phrases will be built into AppShortcuts.xcstrings
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: OpenCategory(),
      phrases: [
        "Open \(\.$target) in \(.applicationName)",
        "Show \(\.$target) in \(.applicationName)",
      ],
      shortTitle: "Open Category", systemImageName: "building.columns")
    AppShortcut(
      intent: ShowConcerts(),
      phrases: [
        "Show \(\.$artist) concerts in \(.applicationName)",
        "Show shows by \(\.$artist) in \(.applicationName)",
      ],
      shortTitle: "Concerts by Artist", systemImageName: "person.and.background.dotted")
    AppShortcut(
      intent: ShowConcerts(),
      phrases: [
        "Show concerts at \(\.$venue) in \(.applicationName)",
        "Show shows at \(\.$venue) in \(.applicationName)",
      ],
      shortTitle: "Concerts at Venue", systemImageName: "music.note.house")
    AppShortcut(
      intent: ShowConcerts(),
      phrases: [
        "Show \(.applicationName) concerts in \(\.$city)",
        "Show shows in \(\.$city) in \(.applicationName)",
      ],
      shortTitle: "Concerts in City", systemImageName: "building.2")
    AppShortcut(
      intent: ShowConcertsToday(),
      phrases: [
        "Show concerts today in \(.applicationName)",
        "Show today's shows in \(.applicationName)",
      ],
      shortTitle: "Concerts Today", systemImageName: "calendar.circle")
  }
}
