//
//  ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import Foundation

public enum ArchiveCategory: String, CaseIterable, Codable, Sendable {
  case today
  case shows
  case venues
  case artists
  case stats
  case settings
  case search

  public static var defaultCategory: ArchiveCategory { .today }

  public var localizedString: String {
    switch self {
    case .today:
      return String(localized: "Today")
    case .stats:
      return String(localized: "Stats")
    case .shows:
      return String(localized: "Shows")
    case .venues:
      return String(localized: "Venues")
    case .artists:
      return String(localized: "Artists")
    case .settings:
      return String(localized: "Settings")
    case .search:
      return String(localized: "Search")
    }
  }

  public var systemImage: String {
    switch self {
    case .today:
      "calendar.circle"
    case .stats:
      "chart.bar"
    case .shows:
      "person.and.background.dotted"
    case .venues:
      "music.note.house"
    case .artists:
      "music.mic"
    case .settings:
      "gear"
    case .search:
      "magnifyingglass"
    }
  }

  public var title: String {
    switch self {
    case .today:
      return String(localized: "Display Shows On This Date")
    case .stats:
      return String(localized: "Show Statistics")
    case .shows:
      return String(localized: "All Shows")
    case .venues:
      return String(localized: "Show Venues")
    case .artists:
      return String(localized: "Show Artists")
    case .settings:
      return String(localized: "Settings")
    case .search:
      return localizedString
    }
  }
}
