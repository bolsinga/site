//
//  MusicDestinationModifier.swift
//
//
//  Created by Greg Bolsinga on 4/6/23.
//

import CoreLocation
import SwiftUI

struct MusicDestinationModifier: ViewModifier {
  let vault: Vault
  let isPathNavigable: (PathRestorable) -> Bool

  func body(content: Content) -> some View {
    content
      .navigationDestination(for: ArchivePath.self) {
        $0.destination(vault: vault, isPathNavigable: isPathNavigable)
      }
  }
}

extension View {
  func musicDestinations(_ vault: Vault, path: [ArchivePath] = []) -> some View {
    modifier(MusicDestinationModifier(vault: vault, isPathNavigable: path.isPathNavigable(_:)))
  }
}
