//
//  ArchiveSharableModifier.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

struct ArchiveSharableModifier<T: ArchiveSharable & Linkable>: ViewModifier {
  let item: T?

  func body(content: Content) -> some View {
    #if os(tvOS)
      content  // ShareLink not available on tvOS
    #else
      if let item, let url = item.url {
        content
          .toolbar { ArchiveSharableToolbarContent(item: item, url: url) }
      } else {
        content
      }
    #endif
  }
}

extension View {
  func archiveShare<T: ArchiveSharable & Linkable>(_ item: T?) -> some View {
    modifier(ArchiveSharableModifier(item: item))
  }
}
