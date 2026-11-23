//
//  SiteModel.swift
//
//
//  Created by Greg Bolsinga on 11/23/23.
//

import Foundation
import Shared
import os

extension Logger {
  fileprivate static let vaultLoader = Logger(category: "vaultLoader")
}

@Observable public final class SiteModel {
  public enum Reason {
    case preview
    case initial
    case refresh
    case errorRetry

    /// The first load of a launch joins one an intent started, and the others ask again.
    fileprivate var joinsRunningLoad: Bool {
      if case .initial = self { return true }
      return false
    }

    fileprivate var executeAsynchronousTasks: Bool {
      switch self {
      case .preview:
        false
      default:
        true
      }
    }
  }

  private let urlString: String

  public var vaultModel: VaultModel?

  /// Does the loading when there is one, so App Intents and the app share it.
  @ObservationIgnored public var vaultProvider: (any VaultLoading)?
  public var error: Error?

  /// Makes the model of a loaded archive, which a test gives its own services.
  @ObservationIgnored public var makeVaultModel: @MainActor (Vault, Bool) -> VaultModel = {
    VaultModel($0, executeAsynchronousTasks: $1)
  }

  #if !os(tvOS)
    /// The latest widget snapshot publish, so the next one can cancel it.
    @ObservationIgnored public var widgetPublish: Task<Void, Never>?

    /// What a load asks of the system, which a test replaces.
    @ObservationIgnored public var writeWidgetSnapshot:
      @Sendable (ShowsTodaySnapshot) throws -> Bool = {
        try $0.write()
      }
    @ObservationIgnored public var reloadWidgetTimelines: @MainActor @Sendable () -> Void = {}
    @ObservationIgnored public var indexSpotlight: @Sendable (Vault) async -> Void = { _ in }
  #endif

  /// Loads can overlap, as a refresh can start while another load is still going. The one that
  /// started last wins, however the network orders their results.
  @ObservationIgnored
  private var loadCount = 0

  public init(urlString: String, vaultModel: VaultModel? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vaultModel = vaultModel
    self.error = error
  }

  private func policy(_ reason: Reason) -> Lookup.LoadPolicy {
    switch reason {
    case .preview, .errorRetry:
      .download
    case .initial, .refresh:
      .savedIfCurrent
    }
  }

  @MainActor
  public func load(_ reason: Reason) async {
    Logger.vaultLoader.log("start: \(String(describing: reason), privacy: .public)")
    defer {
      Logger.vaultLoader.log("end: \(String(describing: reason), privacy: .public)")
    }
    loadCount += 1
    let request = loadCount
    do {
      error = nil

      let vault: Vault
      if let vaultProvider {
        vault = try await vaultProvider.load(
          policy: policy(reason), joining: reason.joinsRunningLoad)
      } else {
        vault = try await Vault.load(urlString, policy: policy(reason))
      }
      guard request == loadCount else {
        Logger.vaultLoader.log("superseded: \(String(describing: reason), privacy: .public)")
        return
      }

      vaultModel?.cancelTasks()
      vaultModel = makeVaultModel(vault, reason.executeAsynchronousTasks)

      #if !os(tvOS)
        if reason.executeAsynchronousTasks {
          publishWidgetSnapshot(vault)
        }
      #endif

      #if !os(tvOS)
        if reason.executeAsynchronousTasks {
          await indexSpotlight(vault)
        }
      #endif
    } catch {
      guard request == loadCount else {
        Logger.vaultLoader.log("superseded: \(String(describing: reason), privacy: .public)")
        return
      }
      // A cancelled load, such as a pull to refresh that was let go, isn't a failure to show.
      guard !Task.isCancelled else {
        Logger.vaultLoader.log("cancelled: \(String(describing: reason), privacy: .public)")
        return
      }
      Logger.vaultLoader.fault("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }
}
