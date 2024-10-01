//
//  ArchiveSharableToolbar.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct ArchiveSharableToolbar<T: ArchiveSharable>: ToolbarContent {
  let item: T
  let url: URL

  var body: some ToolbarContent {
    ToolbarItem(placement: .primaryAction) {
      ShareLink(
        item: url, subject: item.subject, message: item.message,
        preview: SharePreview(item.subject, image: Bundle.main.appIcon))
    }
  }
}
