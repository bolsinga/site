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
  public static func load(
    url: URL,
    artistsWithShowsOnly: Bool = true
  ) async throws -> (Music, Date) {
    Logger.music.log("start: \(String(describing: url))")
    defer {
      Logger.music.log("end")
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    var lastModified = Date.distantPast
    if let lastModifiedDate = try response.lastModified() {
      lastModified = lastModifiedDate
    }

    let music: Music = try data.fromJSON()
    return artistsWithShowsOnly ? (music.showsOnly, lastModified) : (music, lastModified)
  }
}
