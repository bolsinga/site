//
//  Music+URL.swift
//
//
//  Created by Greg Bolsinga on 4/24/23.
//

import Foundation
import MusicData
import Utilities
import os

extension Logger {
  fileprivate static let url = Logger(category: "url")
  fileprivate static let music = Logger(category: "music")
}

extension Music {
  public static func load(url: URL) async throws -> Music {
    Logger.music.log("start")
    defer {
      Logger.music.log("end")
    }

    Logger.url.log("start: \(url.absoluteString, privacy: .public)")
    let (data, _) = try await URLSession.shared.data(from: url)
    Logger.url.log("end")

    let music: Music = try data.fromJSON()
    return music
  }
}
