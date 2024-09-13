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
    #if os(tvOS)
      content  // ShareLink not available on tvOS
    #else
      if let url {
        content
          .toolbar {
            ShareLink(
              item: url, subject: category.subject, message: category.message,
              preview: SharePreview(
                category.subject, image: Bundle.main.appIcon))
          }
      } else {
        content
      }
    #endif
  }
}

extension View {
  func shareCategory(_ category: ArchiveCategory, url: URL?) -> some View {
    modifier(ArchiveCategoryShareModifier(category: category, url: url))
  }
}
