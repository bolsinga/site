//
//  PathRestorableShareModifier.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

struct PathRestorableShareModifier<T: ArchiveSharable>: ViewModifier {
  let item: T
  let url: URL?

  func body(content: Content) -> some View {
    #if os(tvOS)
      content  // ShareLink not available on tvOS
    #else
      if let url {
        content
          .toolbar {
            ShareLink(
              item: url, subject: item.subject, message: item.message,
              preview: SharePreview(item.subject, image: Bundle.main.appIcon))
          }
      } else {
        content
      }
    #endif
  }
}

extension View {
  func sharePathRestorable<T: ArchiveSharable>(_ item: T, url: URL?) -> some View {
    modifier(PathRestorableShareModifier(item: item, url: url))
  }
}
