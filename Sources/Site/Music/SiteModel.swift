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
    case initial(Date)
    case refresh
    case errorRetry

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
  internal var error: Error?

  var lastModified: Date = .distantPast

  /// Loads can overlap, as a refresh can start while another load is still going. The one that
  /// started last wins, however the network orders their results.
  @ObservationIgnored
  private var loadCount = 0

  public init(urlString: String, vaultModel: VaultModel? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vaultModel = vaultModel
    self.error = error
  }

  private func modifiedDate(_ reason: Reason) -> Date {
    switch reason {
    case .preview, .errorRetry:
      .distantPast
    case .initial(let date):
      date
    case .refresh:
      lastModified
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

      let vault = try await Vault.load(
        urlString,
        identifier: BasicIdentifier(),
        previousModified: modifiedDate(reason))
      guard request == loadCount else {
        Logger.vaultLoader.log("superseded: \(String(describing: reason), privacy: .public)")
        return
      }
      self.lastModified = vault.timestamp

      vaultModel?.cancelTasks()
      vaultModel = VaultModel(vault, executeAsynchronousTasks: reason.executeAsynchronousTasks)

      #if !os(tvOS)
        if reason.executeAsynchronousTasks {
          publishWidgetSnapshot(vault)
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
