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
  @Published var todayShows: [Show] = []

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
      updateTodayShows()
      Task {
        await monitorDayChanges()
      }
    } catch {
      Logger.vaultModel.log("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }

  private func updateTodayShows() {
    guard let vault else {
      Logger.vaultModel.log("No Vault to calculate todayShows.")
      return
    }

    todayShows = vault.music.showsOnDate(Date.now).sorted {
      vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }

    Logger.vaultModel.log("Today Count: \(self.todayShows.count, privacy: .public)")
  }

  private func monitorDayChanges() async {
    Logger.vaultModel.log("start day monitoring")
    defer {
      Logger.vaultModel.log("end day monitoring")
    }
    for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
      Logger.vaultModel.log("day changed")
      updateTodayShows()
    }
  }
}
