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
    case .today, .stats, .settings:
      return false
    case .shows, .venues, .artists:
      return true
    }
  }

  fileprivate func url(baseURL: URL) -> URL? {
    var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = self.formatted(.urlPath)
    return urlComponents?.url
  }

  static func urls(baseURL: URL) -> [ArchiveCategory: URL] {
    self.allCases.filter { $0.isURLSharable }.reduce(into: [ArchiveCategory: URL]()) {
      guard let url = $1.url(baseURL: baseURL) else { return }
      $0[$1] = url
    }
  }
}
