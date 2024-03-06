//
//  Music+URL.swift
//
//
//  Created by Greg Bolsinga on 4/24/23.
//

import Foundation
import os

extension Music {
  public static func load(url: URL) async throws -> Music {
    let musicLogger = Logger(category: "music")
    musicLogger.log("start")
    defer {
      musicLogger.log("end")
    }

    let urlLogger = Logger(category: "url")
    urlLogger.log("start: \(url.absoluteString, privacy: .public)")
    let (data, _) = try await URLSession.shared.data(from: url)
    urlLogger.log("end")

    let music: Music = try data.fromJSON()
    return music
  }
}
