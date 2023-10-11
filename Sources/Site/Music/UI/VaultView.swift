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
  private var model: VaultModel

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
        VStack(alignment: .center) {
          Text(error.localizedDescription)
          Button {
            Task {
              Logger.vaultLoad.log("User retry")
              await model.load()
            }
          } label: {
            Label(
              String(
                localized: "Retry", bundle: .module,
                comment: "Title for the Retry button when the Model could not be created."),
              systemImage: "arrow.clockwise")
          }
          .buttonStyle(.borderedProminent)
        }
      } else {
        ProgressView()
      }
    }.task {
      guard model.vault == nil, model.error == nil else { return }

      Logger.vaultLoad.log("start task")
      defer {
        Logger.vaultLoad.log("end task")
      }
      await model.load()
    }
  }
}

#Preview {
  VaultView(VaultModel(urlString: "https://www.example.com", error: VaultError.illegalURL("err")))
}

#Preview {
  VaultView(VaultModel(urlString: "https://www.example.com"))
}

#Preview {
  VaultView(VaultModel(urlString: "https://www.example.com", vault: vaultPreviewData))
}
