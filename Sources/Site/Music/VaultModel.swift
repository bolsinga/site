//
//  VaultModel.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

import Combine
import Foundation
import os

extension Logger {
  static let vaultModel = Logger(category: "vaultModel")
}

@MainActor public final class VaultModel: ObservableObject {
  let url: URL

  @Published var vault: Vault?
  @Published var error: Error?

  public init(url: URL) {
    self.url = url
  }

  func load() async {
    Logger.vaultModel.log("start")
    defer {
      Logger.vaultModel.log("end")
    }
    do {
      vault = try await Vault.load(url: url)
    } catch {
      Logger.vaultModel.log("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }
}
