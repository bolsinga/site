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
  private let urlString: String

  public var vaultModel: VaultModel?
  internal var error: Error?

  public init(urlString: String, vaultModel: VaultModel? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vaultModel = vaultModel
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

      let vault = try await Vault.load(urlString)

      vaultModel?.cancelTasks()
      vaultModel = VaultModel(vault)
    } catch {
      Logger.vaultLoader.fault("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }
}
