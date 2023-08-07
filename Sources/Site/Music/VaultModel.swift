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
      await monitorDayChanges()
    } catch {
      Logger.vaultModel.log("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }

  private func updateTodayShows() {
    guard let vault else { fatalError("strange days") }

    todayShows = vault.music.showsOnDate(Date.now).sorted {
      vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }

    Logger.vaultModel.log("Today Count: \(self.todayShows.count, privacy: .public)")
  }

  private func monitorDayChanges() async {
    for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
      updateTodayShows()
    }
  }
}
