//
//  VenuePlacesCommand.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import SwiftUI

/// What the Venue Places window does for the File menu's commands.
struct VenuePlacesActions {
  let save: () -> Void
  let saveAs: () -> Void
}

extension FocusedValues {
  @Entry var venuePlacesActions: VenuePlacesActions?
}

#if !os(tvOS)
  /// Opens the Venue Places window from the Window menu, and saves its venuemap.txt from the File
  /// menu, only where the tool is enabled.
  struct VenuePlacesCommand: Commands {
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.venuePlacesActions) private var actions

    var body: some Commands {
      CommandGroup(replacing: .saveItem) {
        if VenuePlaces.isEnabled {
          Button("Save") { actions?.save() }
            .keyboardShortcut("s")
            .disabled(actions == nil)
          Button("Save As…") { actions?.saveAs() }
            .keyboardShortcut("s", modifiers: [.command, .shift])
            .disabled(actions == nil)
        }
      }
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
