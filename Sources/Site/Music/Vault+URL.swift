//
//  Vault+URL.swift
//
//
//  Created by Greg Bolsinga on 4/20/23.
//

import Foundation
import os

extension Logger {
  static let vault = Logger(category: "vault")
}

extension Vault {
  public static func load(url: URL, artistsWithShowsOnly: Bool = true) async throws -> Vault {
    Logger.vault.log("start")
    defer {
      Logger.vault.log("end")
    }
    let music = try await Music.load(url: url)
    return await Vault.create(music: artistsWithShowsOnly ? music.showsOnly : music, url: url)
  }
}
