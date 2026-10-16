//
//  URLResponse+LastModified.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/23/26.
//

import Foundation

extension URLResponse {
  func lastModified() throws -> Date? {
    var lastModified: Date? = nil
    if let httpResponse = self as? HTTPURLResponse {
      if let lastModifiedString = httpResponse.value(forHTTPHeaderField: "Last-Modified") {
        lastModified = try Date(lastModifiedString, strategy: .http)
      }
    }
    return lastModified
  }
}
