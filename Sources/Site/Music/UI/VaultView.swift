//
//  VaultView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI
import os

extension Logger {
  static let vaultLoad = Logger(category: "vaultLoad")
}

public struct VaultView: View {
  let url: URL

  @State private var vault: Vault? = nil
  @State private var error: Error? = nil

  public init(url: URL) {
    self.url = url
  }

  private func loadVault() async {
    Logger.vaultLoad.log("start")
    defer {
      Logger.vaultLoad.log("end")
    }
    do {
      vault = try await Vault.load(url: url)
    } catch {
      Logger.vaultLoad.log("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }

  public var body: some View {
    Group {
      if let vault {
        ArchiveCategorySplit(vault: vault)
          .refreshable {
            Logger.vaultLoad.log("refresh")
            await loadVault()
          }
      } else if let error {
        Text(error.localizedDescription)
      } else {
        ProgressView()
      }
    }.task {
      Logger.vaultLoad.log("task")
      await loadVault()
    }
  }
}
