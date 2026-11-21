//
//  VaultProvider.swift
//  site
//
//  Created by Greg Bolsinga on 11/20/26.
//

import Foundation
import Shared
import os

extension Logger {
  fileprivate static let vaultProvider = Logger(category: "vaultProvider")
}

/// The archive for App Intents, which can run before the app has a scene to load it.
actor VaultProvider {
  private struct Loaded {
    let vault: Vault
    let catalog: EntityCatalog
  }

  private let urlString: String
  private let previousModified: @Sendable () -> Date
  private let load: @Sendable (String, Date) async throws -> Vault

  private var loaded: Loaded?
  private var loading: Task<Vault, any Error>?

  init(
    urlString: String,
    previousModified: @escaping @Sendable () -> Date = {
      UserDefaults.standard.object(forKey: "music.last.modified") as? Date ?? .distantPast
    },
    load: @escaping @Sendable (String, Date) async throws -> Vault = {
      try await Vault.load($0, previousModified: $1)
    }
  ) {
    self.urlString = urlString
    self.previousModified = previousModified
    self.load = load
  }

  /// The loaded vault, or a load of it that is shared by whoever asks while it runs.
  func vault() async throws -> Vault {
    if let loaded { return loaded.vault }
    return try await finishLoading().vault
  }

  /// Every entity of the vault, kept until the next one is loaded.
  func catalog() async throws -> EntityCatalog {
    if let loaded { return loaded.catalog }
    return try await finishLoading().catalog
  }

  /// Keeps the vault that the app loaded, in place of any earlier one.
  func use(_ vault: Vault) {
    loaded = Loaded(vault: vault, catalog: EntityCatalog(vault: vault))
  }

  private func finishLoading() async throws -> Loaded {
    let task = loading ?? startLoading()
    do {
      let vault = try await task.value
      loading = nil
      if let loaded { return loaded }
      use(vault)
      return loaded ?? Loaded(vault: vault, catalog: EntityCatalog(vault: vault))
    } catch {
      loading = nil
      Logger.vaultProvider.error("load failed: \(error.localizedDescription, privacy: .public)")
      throw error
    }
  }

  private func startLoading() -> Task<Vault, any Error> {
    Logger.vaultProvider.log("start")
    let task = Task { [urlString, previousModified, load] in
      try await load(urlString, previousModified())
    }
    loading = task
    return task
  }
}
