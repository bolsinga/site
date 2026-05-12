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

extension Vault where Identifier: ArchiveIdentifier {
  public static func load(_ urlString: String, identifier: Identifier) async throws
    -> Vault<Identifier>
  {
    Logger.vault.log("start")
    defer {
      Logger.vault.log("end")
    }

    guard let url = URL(string: urlString) else { throw VaultError.illegalURL(urlString) }

    return try await Vault(url: url, identifier: identifier)
  }
}
