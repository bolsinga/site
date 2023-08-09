//
//  ArchiveCategoryShareModifier.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import SwiftUI

extension ArchiveCategory {
  private var descriptor: String {
    switch self {
    case .today:
      return String(
        localized: "Shows Today: \(Date.now.formatted(.dateTime.month(.defaultDigits).day()))",
        bundle: .module, comment: "Today Shows shared string")
    default:
      return self.localizedString
    }
  }

  var subject: Text {
    Text(self.descriptor)
  }

  var message: Text {
    Text(self.descriptor)
  }
}

struct ArchiveCategoryShareModifier: ViewModifier {
  @Environment(\.vault) var vault: Vault

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
