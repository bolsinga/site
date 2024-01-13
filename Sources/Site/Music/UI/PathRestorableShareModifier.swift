//
//  PathRestorableShareModifier.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

struct PathRestorableShareModifier<T: PathRestorableShareable>: ViewModifier {
  let item: T
  let url: URL?

  func body(content: Content) -> some View {
    content
      #if os(iOS) || os(macOS)
        .toolbar {
          if let url {
            ShareLink(
              item: url, subject: item.subject, message: item.message,
              preview: SharePreview(
                item.subject, image: Bundle.main.appIcon))
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
  func sharePathRestorable<T: PathRestorableShareable>(_ item: T, url: URL?) -> some View {
    modifier(PathRestorableShareModifier(item: item, url: url))
  }
}
