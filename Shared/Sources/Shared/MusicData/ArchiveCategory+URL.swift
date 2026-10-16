//
//  ArchiveCategory+URL.swift
//  site
//
//  Created by Greg Bolsinga on 9/26/24.
//

import Foundation

extension ArchiveCategory {
  func url(rootURL: URL) -> URL? {
    var urlComponents = URLComponents(url: rootURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = self.formatted(.urlPath)
    return urlComponents?.url
  }
}
