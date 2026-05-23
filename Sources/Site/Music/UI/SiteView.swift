//
//  SiteView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI

public struct SiteView: View {
  private let model: SiteModel

  public init(_ model: SiteModel) {
    self.model = model
  }

  public var body: some View {
    Group {
      if let vaultModel = model.vaultModel {
        ArchiveStateView {
          await model.load(.refresh)
        }
        .environment(vaultModel)
      } else if let error = model.error {
        VStack(alignment: .center) {
          ContentUnavailableView(
            error.localizedDescription, systemImage: "network.slash",
            description: Text("Unable to load data."))
          Button {
            Task {
              await model.load(.errorRetry)
            }
          } label: {
            Label(String(localized: "Retry"), systemImage: "arrow.clockwise")
          }
          .buttonStyle(.borderedProminent)
        }
      } else {
        ProgressView()
      }
    }.task {
      guard model.vaultModel == nil, model.error == nil else { return }

      await model.load(.initial)
    }
  }
}

#Preview {
  SiteView(SiteModel(urlString: "https://www.example.com", error: VaultError.illegalURL("err")))
}

#Preview {
  SiteView(SiteModel(urlString: "https://www.example.com"))
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  SiteView(
    SiteModel(
      urlString: "https://www.example.com",
      vaultModel: model))
}
