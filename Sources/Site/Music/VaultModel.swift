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
  @Published var todayConcerts: [Concert] = []

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
      updateTodayConcerts()
      Task {
        await monitorDayChanges()
      }
    } catch {
      Logger.vaultModel.log("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }

  private func updateTodayConcerts() {
    guard let vault else {
      Logger.vaultModel.log("No Vault to calculate todayConcerts.")
      return
    }

    todayConcerts = vault.music.showsOnDate(Date.now).sorted {
      vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }.map { vault.concert(from: $0) }

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
