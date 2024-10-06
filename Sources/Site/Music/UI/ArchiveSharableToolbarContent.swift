//
//  ArchiveSharableToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

#if !os(tvOS)
  struct ArchiveSharableToolbarContent: ToolbarContent {
    let placement: ToolbarItemPlacement
    let item: ArchiveSharable
    let url: URL

    internal init(placement: ToolbarItemPlacement = .primaryAction, item: ArchiveSharable, url: URL)
    {
      self.placement = placement
      self.item = item
      self.url = url
    }

    var body: some ToolbarContent {
      ToolbarItem(placement: placement) {
        ShareLink(
          item: url, subject: Text(item.subject), message: Text(item.message),
          preview: SharePreview(Text(item.subject), image: Bundle.main.appIcon))
      }
    }
  }
#endif
