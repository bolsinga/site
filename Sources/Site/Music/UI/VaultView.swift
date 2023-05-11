//
//  VaultView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI

public struct VaultView: View {
  let url: URL

  @State private var vault: Vault? = nil
  @State private var error: Error? = nil

  public init(url: URL) {
    self.url = url
  }

  private func refresh() async {
    do {
      vault = try await Vault.load(url: url)
    } catch {
      self.error = error
    }
  }

  public var body: some View {
    Group {
      if let vault {
        ArchiveCategoryList(vault: vault)
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
