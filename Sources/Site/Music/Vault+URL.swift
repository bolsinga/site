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

enum VaultError: Error {
  case illegalURL(String)
}

extension VaultError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .illegalURL(let urlString):
      return "URL (\(urlString)) is not valid."
    }
  }
}

extension Vault {
  public static func load(_ urlString: String) async throws -> Vault {
    guard let url = URL(string: urlString) else { throw VaultError.illegalURL(urlString) }

    return try await Vault.load(url: url)
  }

  public static func load(url: URL, artistsWithShowsOnly: Bool = true) async throws -> Vault {
    Logger.vault.log("start")
    defer {
      Logger.vault.log("end")
    }
    let music = try await Music.load(url: url)
    return await Vault.create(music: artistsWithShowsOnly ? music.showsOnly : music, url: url)
  }
}
