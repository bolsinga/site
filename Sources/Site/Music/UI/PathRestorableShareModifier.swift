//
//  PathRestorableShareModifier.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

struct PathRestorableShareModifier<T: PathRestorableShareable>: ViewModifier {
  @Environment(\.vault) var vault: Vault

  let item: T

  func body(content: Content) -> some View {
    content
      .toolbar {
        if let url = vault.createURL(for: item.archivePath) {
          ShareLink(
            item: url, subject: item.subject(vault: vault), message: item.message(vault: vault))
        }
      }
  }
}

extension View {
  func sharePathRestorable<T: PathRestorableShareable>(_ item: T) -> some View {
    modifier(PathRestorableShareModifier(item: item))
  }
}
