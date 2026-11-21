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

/// Where the date of the last load is kept, as `Date`, so the next launch can ask if it is stale.
let musicLastModifiedKey = "music.last.modified"

/// Loads the archive for the app and for App Intents, which can run before there is a scene.
actor VaultProvider {
  private struct Loaded {
    let vault: Vault
    let catalog: EntityCatalog
  }

  private struct Running {
    let generation: Int
    let task: Task<Vault, any Error>
  }

  private let urlString: String
  private let previousModified: @Sendable () -> Date
  private let storeLastModified: @Sendable (Date) -> Void
  private let load: @Sendable (String, Date) async throws -> Vault

  private var loaded: Loaded?
  private var loading: Running?
  private var generation = 0
  private var loadedGeneration = 0

  init(
    urlString: String,
    previousModified: @escaping @Sendable () -> Date = {
      UserDefaults.standard.object(forKey: musicLastModifiedKey) as? Date ?? .distantPast
    },
    storeLastModified: @escaping @Sendable (Date) -> Void = {
      UserDefaults.standard.set($0, forKey: musicLastModifiedKey)
    },
    load: @escaping @Sendable (String, Date) async throws -> Vault = {
      try await Vault.load($0, previousModified: $1)
    }
  ) {
    self.urlString = urlString
    self.previousModified = previousModified
    self.storeLastModified = storeLastModified
    self.load = load
  }

  /// The loaded vault, or a load of it that is shared by whoever asks while it runs.
  func vault() async throws -> Vault {
    if let loaded { return loaded.vault }
    return try await load(previousModified: previousModified(), joining: true)
  }

  /// Every entity of the vault, kept until the next one is loaded.
  func catalog() async throws -> EntityCatalog {
    if let loaded { return loaded.catalog }
    let vault = try await vault()
    return loaded?.catalog ?? EntityCatalog(vault: vault)
  }

  /// Loads the vault. A load that is already running is joined when `joining`, and a load that
  /// isn't joining starts its own, in the caller's task, so cancelling the caller cancels it.
  func load(previousModified: Date, joining: Bool) async throws -> Vault {
    if joining, let loading {
      Logger.vaultProvider.log("join")
      return try await loading.task.value
    }

    generation += 1
    let started = generation
    if joining {
      let task = Task { [urlString, load] in try await load(urlString, previousModified) }
      loading = Running(generation: started, task: task)
      return try await finish(started) { try await task.value }
    }
    return try await finish(started) { [urlString, load] in
      try await load(urlString, previousModified)
    }
  }

  /// Keeps a vault that was made without a load, in place of any earlier one.
  func use(_ vault: Vault) {
    generation += 1
    keep(vault, generation: generation)
  }

  private func finish(_ started: Int, _ work: () async throws -> Vault) async throws -> Vault {
    do {
      let vault = try await work()
      if loading?.generation == started { loading = nil }
      keep(vault, generation: started)
      return vault
    } catch {
      if loading?.generation == started { loading = nil }
      Logger.vaultProvider.error("load failed: \(error.localizedDescription, privacy: .public)")
      throw error
    }
  }

  /// Only the load that started last is kept, whatever order they finish in.
  private func keep(_ vault: Vault, generation: Int) {
    guard generation > loadedGeneration else { return }
    loadedGeneration = generation
    loaded = Loaded(vault: vault, catalog: EntityCatalog(vault: vault))
    storeLastModified(vault.timestamp)
  }
}
