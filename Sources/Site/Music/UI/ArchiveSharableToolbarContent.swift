//
//  ArchiveSharableToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct ArchiveSharableToolbarContent<T: ArchiveSharable>: ToolbarContent {
  let placement: ToolbarItemPlacement
  let item: T
  let url: URL?

  internal init(placement: ToolbarItemPlacement = .primaryAction, item: T, url: URL?) {
    self.placement = placement
    self.item = item
    self.url = url
  }

  var body: some ToolbarContent {
    if let url {
      ToolbarItem(placement: placement) {
        #if !os(tvOS)
          ShareLink(
            item: url, subject: Text(item.subject), message: Text(item.message),
            preview: SharePreview(Text(item.subject), image: Bundle.main.appIcon))
        #else
          EmptyView()
        #endif
      }
    }
  }
}
