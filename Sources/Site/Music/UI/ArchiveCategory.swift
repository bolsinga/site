//
//  ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

public enum ArchiveCategory: String, CaseIterable, Codable, Sendable {
  case today
  case stats
  case shows
  case venues
  case artists
  case settings

  static var defaultCategory: ArchiveCategory? { .today }

  var localizedString: String {
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
    }
  }

  var systemImage: String {
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
    }
  }

  @ViewBuilder var label: some View {
    Label(localizedString, systemImage: systemImage)
  }

  var title: String {
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
    }
  }
}
