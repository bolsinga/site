//
//  ArchivePath+URL.swift
//
//
//  Created by Greg Bolsinga on 9/2/23.
//

import Foundation
import MusicData

extension ArchivePath {
  func url(using rootURL: URL) -> URL? {
    var urlComponents = URLComponents(url: rootURL, resolvingAgainstBaseURL: false)
    urlComponents?.path = self.formatted(.urlPath)
    return urlComponents?.url
  }
}
