//
//  ArchiveSharableToolbar.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

#if !os(tvOS)
  struct ArchiveSharableToolbar<T: ArchiveSharable>: ToolbarContent {
    let placement: ToolbarItemPlacement
    let item: T
    let url: URL

    internal init(placement: ToolbarItemPlacement = .primaryAction, item: T, url: URL) {
      self.placement = placement
      self.item = item
      self.url = url
    }

    var body: some ToolbarContent {
      ToolbarItem(placement: placement) {
        ShareLink(
          item: url, subject: item.subject, message: item.message,
          preview: SharePreview(item.subject, image: Bundle.main.appIcon))
      }
    }
  }
#endif
