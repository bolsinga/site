//
//  ArchiveCategory.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

enum ArchiveCategory {
  case shows
  case venues
  case artists

  var localizedString: String {
    switch self {
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
    case .shows:
      Label(self.localizedString, systemImage: "person.and.background.dotted")
    case .venues:
      Label(self.localizedString, systemImage: "music.note.house")
    case .artists:
      Label(self.localizedString, systemImage: "music.mic")
    }
  }
}
