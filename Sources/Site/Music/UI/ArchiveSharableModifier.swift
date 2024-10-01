//
//  ArchiveSharableModifier.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

struct ArchiveSharableModifier<T: ArchiveSharable>: ViewModifier {
  let item: T
  let url: URL?

  func body(content: Content) -> some View {
    #if os(tvOS)
      content  // ShareLink not available on tvOS
    #else
      if let url {
        content
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              ShareLink(
                item: url, subject: item.subject, message: item.message,
                preview: SharePreview(item.subject, image: Bundle.main.appIcon))
            }
          }
      } else {
        content
      }
    #endif
  }
}

extension View {
  func archiveShare<T: ArchiveSharable & Linkable>(_ item: T) -> some View {
    modifier(ArchiveSharableModifier(item: item, url: item.url))
  }

  func archiveShare<T: ArchiveSharable>(_ item: T, url: URL?) -> some View {
    modifier(ArchiveSharableModifier(item: item, url: url))
  }
}
