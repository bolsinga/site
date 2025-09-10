//
//  RefreshCommand.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

import SwiftUI

#if !os(tvOS)
  public struct RefreshCommand: Commands, Sendable {
    private let refreshAction: (@MainActor @Sendable () async -> Void)

    public init(refreshAction: (@escaping @MainActor @Sendable () async -> Void)) {
      self.refreshAction = refreshAction
    }

    public var body: some Commands {
      CommandGroup(after: .newItem) {
        Button {
          Task { @MainActor in
            await refreshAction()
          }
        } label: {
          Text("Refresh")
        }
        .keyboardShortcut(KeyboardShortcut(KeyEquivalent("r"), modifiers: [.command]))
      }
    }
  }
#endif
