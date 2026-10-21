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
  case settings
  case search

  public static var defaultCategory: ArchiveCategory { .today }

  public var localizedString: String {
    switch self {
    case .today:
      return String(localized: "Today", bundle: #bundle)
    case .shows:
      return String(localized: "Shows", bundle: #bundle)
    case .venues:
      return String(localized: "Venues", bundle: #bundle)
    case .artists:
      return String(localized: "Artists", bundle: #bundle)
    case .settings:
      return String(localized: "Settings", bundle: #bundle)
    case .search:
      return String(localized: "Search", bundle: #bundle)
    }
  }

  public var systemImage: String {
    switch self {
    case .today:
      .nowCalendarSystemImage
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
      return String(localized: "Display Shows On This Date", bundle: #bundle)
    case .shows:
      return String(localized: "All Shows", bundle: #bundle)
    case .venues:
      return String(localized: "Show Venues", bundle: #bundle)
    case .artists:
      return String(localized: "Show Artists", bundle: #bundle)
    case .settings:
      return String(localized: "Settings", bundle: #bundle)
    case .search:
      return localizedString
    }
  }
}
