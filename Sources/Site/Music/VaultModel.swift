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

enum VaultError: Error {
  case illegalURL(String)
}

extension VaultError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .illegalURL(let urlString):
      return "URL (\(urlString)) is not valid."
    }
  }
}

@MainActor public final class VaultModel: ObservableObject {
  let urlString: String

  @Published var vault: Vault?
  @Published var error: Error?
  @Published var todayConcerts: [Concert] = []

  public init(urlString: String, vault: Vault? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vault = vault
    self.error = error
  }

  func load() async {
    Logger.vaultModel.log("start")
    defer {
      Logger.vaultModel.log("end")
    }
    do {
      guard let url = URL(string: urlString) else { throw VaultError.illegalURL(urlString) }

      vault = try await Vault.load(url: url)
      updateTodayConcerts()
      Task {
        await monitorDayChanges()
      }
    } catch {
      Logger.vaultModel.log(
        "error: \(error.localizedDescription, privacy: .public) url: \(self.urlString)")
      self.error = error
    }
  }

  private func updateTodayConcerts() {
    guard let vault else {
      Logger.vaultModel.log("No Vault to calculate todayConcerts.")
      return
    }

    todayConcerts = vault.concerts(on: Date.now)

    Logger.vaultModel.log("Today Count: \(self.todayConcerts.count, privacy: .public)")
  }

  private func monitorDayChanges() async {
    Logger.vaultModel.log("start day monitoring")
    defer {
      Logger.vaultModel.log("end day monitoring")
    }
    for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
      Logger.vaultModel.log("day changed")
      updateTodayConcerts()
    }
  }
}
