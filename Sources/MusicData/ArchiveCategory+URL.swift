//
//  ArchiveCategory+URL.swift
//  site
//
//  Created by Greg Bolsinga on 9/26/24.
//

import Foundation

extension ArchiveCategory {
  var isURLSharable: Bool {
    switch self {
    case .today, .stats, .settings, .search:
      return false
    case .shows, .venues, .artists:
      return true
    }
  }

  func url(rootURL: URL) -> URL? {
    var urlComponents = URLComponents(url: rootURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = self.formatted(.urlPath)
    return urlComponents?.url
  }
}
