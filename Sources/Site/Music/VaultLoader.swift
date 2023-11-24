//
//  VaultLoader.swift
//
//
//  Created by Greg Bolsinga on 11/23/23.
//

import Foundation
import os

extension Logger {
  static let vaultLoader = Logger(category: "vaultLoader")
}

@Observable public final class VaultLoader {
  let urlString: String

  var vault: Vault?
  var error: Error?

  internal init(urlString: String, vault: Vault? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vault = vault
    self.error = error
  }

  @MainActor
  public func load() async {
    Logger.vaultLoader.log("start")
    defer {
      Logger.vaultLoader.log("end")
    }
    do {
      error = nil

      vault = try await Vault.load(urlString)
    } catch {
      Logger.vaultLoader.fault("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }
}
