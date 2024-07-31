//
//  ArchiveTab.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

public enum ArchiveTab: String, CaseIterable {
  case classic

  var localizedString: String {
    switch self {
    case .classic:
      return String(localized: "Classic", bundle: .module)
    }
  }

  @ViewBuilder var label: some View {
    switch self {
    case .classic:
      Label(self.localizedString, systemImage: "clock.arrow.circlepath")
    }
  }
}
