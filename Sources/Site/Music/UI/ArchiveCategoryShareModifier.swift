//
//  ArchiveCategoryShareModifier.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import SwiftUI

extension ArchiveCategory {
  var subject: Text {
    Text(self.title)
  }

  var message: Text {
    Text(self.title)
  }
}

struct ArchiveCategoryShareModifier: ViewModifier {
  @Environment(\.vault) private var vault: Vault

  let category: ArchiveCategory

  func body(content: Content) -> some View {
    content
      .toolbar {
        if let url = vault.createURL(forCategory: category) {
          ShareLink(item: url, subject: category.subject, message: category.message)
        }
      }
  }
}

extension View {
  func shareCategory(_ category: ArchiveCategory) -> some View {
    modifier(ArchiveCategoryShareModifier(category: category))
  }
}
