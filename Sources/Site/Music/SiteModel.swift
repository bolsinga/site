//
//  SiteModel.swift
//
//
//  Created by Greg Bolsinga on 11/23/23.
//

import Foundation
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
    do {
      error = nil

      let vault = try await Vault.load(
        urlString,
        identifier: BasicIdentifier(),
        previousModified: modifiedDate(reason))
      self.lastModified = vault.timestamp

      vaultModel?.cancelTasks()
      vaultModel = VaultModel(vault, executeAsynchronousTasks: reason.executeAsynchronousTasks)
    } catch {
      Logger.vaultLoader.fault("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }
}
