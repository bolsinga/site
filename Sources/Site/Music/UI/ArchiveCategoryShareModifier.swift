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
  let category: ArchiveCategory
  let url: URL?

  func body(content: Content) -> some View {
    content
      #if os(iOS) || os(macOS)
        .toolbar {
          if let url {
            ShareLink(
              item: url, subject: category.subject, message: category.message,
              preview: SharePreview(
                category.subject, image: Bundle.main.appIcon))
          }
        }
      #elseif os(tvOS)
          // ShareLink not available on tvOS
      #else
          // #warning("ShareLink: unknown OS")
      #endif
  }
}

extension View {
  func shareCategory(_ category: ArchiveCategory, url: URL?) -> some View {
    modifier(ArchiveCategoryShareModifier(category: category, url: url))
  }
}
