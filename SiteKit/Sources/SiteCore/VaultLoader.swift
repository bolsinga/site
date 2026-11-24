//
//  VaultLoader.swift
//  site
//
//  Created by Greg Bolsinga on 11/20/26.
//

import Foundation
import os

extension Logger {
  fileprivate static let vaultLoader = Logger(category: "vaultLoader")
}

/// What loads the archive for a model, with the policy of the load.
public protocol VaultLoading: Sendable {
  func load(policy: Lookup.LoadPolicy, joining: Bool) async throws -> Vault
}

/// Loads the archive for the app and for App Intents, which can run before there is a scene. It
/// also keeps a value made from each vault it keeps, until the next one is loaded.
public actor VaultLoader<Derived: Sendable>: VaultLoading {
  private struct Loaded {
    public let vault: Vault
    public let derived: Derived
  }

  private struct Running {
    package let generation: Int
    package let task: Task<Vault, any Error>
  }

  private let urlString: String
  private let load: @Sendable (String, Lookup.LoadPolicy) async throws -> Vault
  private let makeDerived: @Sendable (Vault) -> Derived

  private var loaded: Loaded?
  private var loading: Running?
  private var generation = 0
  private var loadedGeneration = 0

  public init(
    urlString: String,
    load: @escaping @Sendable (String, Lookup.LoadPolicy) async throws -> Vault = {
      try await Vault.load($0, policy: $1)
    },
    makeDerived: @escaping @Sendable (Vault) -> Derived
  ) {
    self.urlString = urlString
    self.load = load
    self.makeDerived = makeDerived
  }

  /// The loaded vault, or a load of it that is shared by whoever asks while it runs.
  public func vault() async throws -> Vault {
    if let loaded { return loaded.vault }
    return try await load(policy: .savedIfCurrent, joining: true)
  }

  /// The value made from the vault, kept until the next one is loaded.
  public func derived() async throws -> Derived {
    if let loaded { return loaded.derived }
    let vault = try await vault()
    return loaded?.derived ?? makeDerived(vault)
  }

  /// Loads the vault. A load that is already running is joined when `joining`, and a load that
  /// isn't joining starts its own, in the caller's task, so cancelling the caller cancels it.
  public func load(policy: Lookup.LoadPolicy, joining: Bool) async throws -> Vault {
    if joining, let loading {
      Logger.vaultLoader.log("join")
      return try await loading.task.value
    }

    generation += 1
    let started = generation
    if joining {
      let task = Task { [urlString, load] in try await load(urlString, policy) }
      loading = Running(generation: started, task: task)
      return try await finish(started) { try await task.value }
    }
    return try await finish(started) { [urlString, load] in
      try await load(urlString, policy)
    }
  }

  /// Keeps a vault that was made without a load, in place of any earlier one.
  package func use(_ vault: Vault) {
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
      Logger.vaultLoader.error("load failed: \(error.localizedDescription, privacy: .public)")
      throw error
    }
  }

  /// Only the load that started last is kept, whatever order they finish in.
  private func keep(_ vault: Vault, generation: Int) {
    guard generation > loadedGeneration else { return }
    loadedGeneration = generation
    loaded = Loaded(vault: vault, derived: makeDerived(vault))
  }
}
