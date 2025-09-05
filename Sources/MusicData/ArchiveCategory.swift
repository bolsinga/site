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
      return String(localized: "Today", bundle: .module)
    case .stats:
      return String(localized: "Stats", bundle: .module)
    case .shows:
      return String(localized: "Shows", bundle: .module)
    case .venues:
      return String(localized: "Venues", bundle: .module)
    case .artists:
      return String(localized: "Artists", bundle: .module)
    case .settings:
      return String(localized: "Settings", bundle: .module)
    case .search:
      return String(localized: "Search", bundle: .module)
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
      return String(localized: "Display Shows On This Date", bundle: .module)
    case .stats:
      return String(localized: "Show Statistics", bundle: .module)
    case .shows:
      return String(localized: "All Shows", bundle: .module)
    case .venues:
      return String(localized: "Show Venues", bundle: .module)
    case .artists:
      return String(localized: "Show Artists", bundle: .module)
    case .settings:
      return String(localized: "Settings", bundle: .module)
    case .search:
      return localizedString
    }
  }
}
