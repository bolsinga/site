//
//  URL+LastModified.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/23/26.
//

import Foundation

extension URL {
  private func lastModified() async throws -> Date? {
    var request = URLRequest(url: self)
    request.httpMethod = "HEAD"

    let (_, response) = try await URLSession.shared.data(for: request)

    return try response.lastModified()
  }

  func isUpdated(since lastKnown: Date) async throws -> Bool {
    guard let lastModified = try await lastModified() else { return true }
    return lastModified > lastKnown
  }
}
