//
//  ArchivePath+URL.swift
//
//
//  Created by Greg Bolsinga on 9/2/23.
//

import Foundation

extension ArchivePath {
  func url(using baseURL: URL?) -> URL? {
    guard let baseURL else {
      return nil
    }
    var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = self.formatted(.urlPath)
    return urlComponents?.url
  }
}
