//
//  RefreshCommand.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

import SwiftUI

#if !os(tvOS)
  public struct RefreshCommand: Commands, Sendable {
    let refreshAction: (@Sendable () async -> Void)

    public init(refreshAction: (@escaping @Sendable () async -> Void)) {
      self.refreshAction = refreshAction
    }

    public var body: some Commands {
      CommandGroup(after: .newItem) {
        Button {
          Task { await refreshAction() }
        } label: {
          Text("Refresh", bundle: .module)
        }
        .keyboardShortcut(KeyboardShortcut(KeyEquivalent("r"), modifiers: [.command]))
      }
    }
  }
#endif
