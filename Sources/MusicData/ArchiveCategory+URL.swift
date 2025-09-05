//
//  ArchiveCategory+URL.swift
//  site
//
//  Created by Greg Bolsinga on 9/26/24.
//

import Foundation

extension ArchiveCategory {
  fileprivate var isURLSharable: Bool {
    switch self {
    case .today, .stats, .settings, .search:
      return false
    case .shows, .venues, .artists:
      return true
    }
  }

  fileprivate func url(rootURL: URL) -> URL? {
    var urlComponents = URLComponents(url: rootURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = self.formatted(.urlPath)
    return urlComponents?.url
  }

  public static func urls(rootURL: URL) -> [ArchiveCategory: URL] {
    self.allCases.filter { $0.isURLSharable }.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(rootURL: rootURL) else { return }
      $0[$1] = url
    }
  }
}
