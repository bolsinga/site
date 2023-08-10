//
//  ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

public enum ArchiveCategory: String, CaseIterable {
  case today
  case stats
  case shows
  case venues
  case artists

  var localizedString: String {
    switch self {
    case .today:
      return String(localized: "Today", bundle: .module, comment: "ArchiveCategory Today")
    case .stats:
      return String(localized: "Stats", bundle: .module, comment: "ArchiveCategory Stats")
    case .shows:
      return String(localized: "Shows", bundle: .module, comment: "ArchiveCategory Shows")
    case .venues:
      return String(localized: "Venues", bundle: .module, comment: "ArchiveCategory Venues")
    case .artists:
      return String(localized: "Artists", bundle: .module, comment: "ArchiveCategory Artists")
    }
  }

  @ViewBuilder var label: some View {
    switch self {
    case .today:
      Label(self.localizedString, systemImage: "calendar.circle")
    case .stats:
      Label(self.localizedString, systemImage: "chart.bar")
    case .shows:
      Label(self.localizedString, systemImage: "person.and.background.dotted")
    case .venues:
      Label(self.localizedString, systemImage: "music.note.house")
    case .artists:
      Label(self.localizedString, systemImage: "music.mic")
    }
  }

  var title: String {
    switch self {
    case .today:
      return String(
        localized:
          "Shows On This Date: \(Date.now.formatted(.dateTime.month(.defaultDigits).day()))",
        bundle: .module, comment: "ArchiveCategory.today shared title")
    case .stats:
      return String(
        localized: "Show Statistics",
        bundle: .module, comment: "ArchiveCategory.stats shared title")
    case .shows:
      return String(
        localized: "All Shows",
        bundle: .module, comment: "ArchiveCategory.shows shared title")
    case .venues:
      return String(
        localized: "Show Venues",
        bundle: .module, comment: "ArchiveCategory.venues shared title")
    case .artists:
      return String(
        localized: "Show Artists",
        bundle: .module, comment: "ArchiveCategory.artists shared title")
    }
  }
}
