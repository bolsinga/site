//
//  URL+LastModified.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/23/26.
//

import Foundation

extension URL {
  private func lastModified(session: URLSession) async throws -> Date? {
    var request = URLRequest(url: self, cachePolicy: .reloadIgnoringLocalCacheData)
    request.httpMethod = "HEAD"

    let (_, response) = try await session.data(for: request)

    return try response.lastModified()
  }

  func isUpdated(since lastKnown: Date, session: URLSession = .shared) async throws -> Bool {
    guard let lastModified = try await lastModified(session: session) else { return true }
    return lastModified > lastKnown
  }
}
