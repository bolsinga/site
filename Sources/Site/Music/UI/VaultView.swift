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
  @ObservedObject private var model: VaultModel

  public init(_ model: VaultModel) {
    self.model = model
  }

  public var body: some View {
    Group {
      if let vault = model.vault {
        ArchiveCategorySplit(vault: vault, model: model)
          .refreshable {
            Logger.vaultLoad.log("start refresh")
            defer {
              Logger.vaultLoad.log("end refresh")
            }
            await model.load()
          }
      } else if let error = model.error {
        Text(error.localizedDescription)
      } else {
        ProgressView()
      }
    }.task {
      Logger.vaultLoad.log("start task")
      defer {
        Logger.vaultLoad.log("end task")
      }
      await model.load()
    }
  }
}
