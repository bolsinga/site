//
//  Vault+URL.swift
//
//
//  Created by Greg Bolsinga on 4/20/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let vault = Logger(category: "vault")
}

extension URL {
  fileprivate var rootURL: URL? {
    let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)

    var newUrlComponents = URLComponents()
    newUrlComponents.host = urlComponents?.host
    newUrlComponents.scheme = urlComponents?.scheme

    return newUrlComponents.url
  }
}

public enum VaultError: Error {
  case illegalURL(String)
  case noRootURL(String)
}

extension VaultError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .illegalURL(let urlString):
      return String(localized: "URL (\(urlString)) is not valid.")
    case .noRootURL(let urlString):
      return String(localized: "URL (\(urlString)) cannot create root URL.")
    }
  }
}

extension Vault where Identifier: ArchiveIdentifier {
  public static func load(_ urlString: String, identifier: Identifier) async throws
    -> Vault<Identifier>
  {
    Logger.vault.log("start")
    defer {
      Logger.vault.log("end")
    }

    guard let url = URL(string: urlString) else { throw VaultError.illegalURL(urlString) }

    let music = try await Music.load(url: url)

    guard let rootURL = url.rootURL else { throw VaultError.noRootURL(url.absoluteString) }

    return try await Vault(music: music, url: rootURL, identifier: identifier)
  }
}
