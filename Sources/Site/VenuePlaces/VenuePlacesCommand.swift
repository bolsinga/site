//
//  VenuePlacesCommand.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import SwiftUI

#if !os(tvOS)
  /// Opens the Venue Places window from the Window menu, only where the tool is enabled.
  struct VenuePlacesCommand: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
      CommandGroup(after: .windowArrangement) {
        if VenuePlaces.isEnabled {
          Button("Venue Places") {
            openWindow(id: VenuePlaces.windowID)
          }
        }
      }
    }
  }
#endif
