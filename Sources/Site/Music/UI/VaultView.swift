//
//  VaultView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI
import os

extension Logger {
  static let refresh = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "refresh")
}

public struct VaultView: View {
  let url: URL

  @State private var vault: Vault? = nil
  @State private var error: Error? = nil

  public init(url: URL) {
    self.url = url
  }

  private func refresh() async {
    Logger.refresh.log("start")
    defer {
      Logger.refresh.log("end")
    }
    do {
      vault = try await Vault.load(url: url)
    } catch {
      Logger.refresh.log("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }

  public var body: some View {
    Group {
      if let vault {
        ArchiveCategorySplit(vault: vault)
          .refreshable {
            await refresh()
          }
      } else if let error {
        Text(error.localizedDescription)
      } else {
        ProgressView()
      }
    }.task {
      await refresh()
    }
  }
}
