//
//  Music+URL.swift
//
//
//  Created by Greg Bolsinga on 4/24/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let music = Logger(category: "music")
}

extension Music {
  package static func load(
    url: URL,
    artistsWithShowsOnly: Bool,
    session: URLSession = .shared
  ) async throws -> (Music, Date) {
    Logger.music.log("start: \(String(describing: url))")
    defer {
      Logger.music.log("end")
    }

    // The server's Last-Modified has already said this is newer, so a cached copy can't be used.
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    let (data, response) = try await session.data(for: request)

    var lastModified = Date.distantPast
    if let lastModifiedDate = try response.lastModified() {
      lastModified = lastModifiedDate
    }

    let music: Music = try data.fromJSON()
    return artistsWithShowsOnly ? (music.showsOnly, lastModified) : (music, lastModified)
  }
}
