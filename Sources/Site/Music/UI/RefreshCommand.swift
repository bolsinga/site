//
//  RefreshCommand.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

import SwiftUI

public struct RefreshCommand: Commands {
  public var model: VaultModel

  public init(model: VaultModel) {
    self.model = model
  }

  public var body: some Commands {
    CommandGroup(after: .newItem) {
      Button {
        Task {
          await model.load()
        }
      } label: {
        Text("Refresh", bundle: .module)
      }
      .keyboardShortcut(KeyboardShortcut(KeyEquivalent("r"), modifiers: [.command]))
    }
  }
}
