//
//  SiteModel.swift
//
//
//  Created by Greg Bolsinga on 11/23/23.
//

import Foundation
import os

@Observable public final class SiteModel {
  let urlString: String

  public var vaultModel: VaultModel?
  var error: Error?

  private let vaultLoader = Logger(category: "vaultLoader")

  public init(urlString: String, vaultModel: VaultModel? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vaultModel = vaultModel
    self.error = error
  }

  @MainActor
  public func load() async {
    vaultLoader.log("start")
    defer {
      vaultLoader.log("end")
    }
    do {
      error = nil

      let vault = try await Vault.load(urlString)

      vaultModel?.cancelTasks()
      vaultModel = VaultModel(vault)
    } catch {
      vaultLoader.fault("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }
}
