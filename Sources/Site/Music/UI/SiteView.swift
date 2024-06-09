//
//  SiteView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI
import os

public struct SiteView: View {
  private var model: SiteModel
  private let vaultLoad = Logger(category: "vaultLoad")

  @State private var searchString = ""

  public init(_ model: SiteModel) {
    self.model = model
  }

  public var body: some View {
    Group {
      if let vaultModel = model.vaultModel {
        ArchiveCategorySplit(model: vaultModel, searchString: $searchString)
          .refreshable {
            vaultLoad.log("start refresh")
            defer {
              vaultLoad.log("end refresh")
            }
            await model.load()
          }
      } else if let error = model.error {
        VStack(alignment: .center) {
          ContentUnavailableView(
            error.localizedDescription, systemImage: "network.slash",
            description: Text("Unable to load data.", bundle: .module))
          Button {
            Task {
              vaultLoad.log("User retry")
              await model.load()
            }
          } label: {
            Label(String(localized: "Retry", bundle: .module), systemImage: "arrow.clockwise")
          }
          .buttonStyle(.borderedProminent)
        }
      } else {
        ProgressView()
      }
    }.task {
      guard model.vaultModel == nil, model.error == nil else { return }

      vaultLoad.log("start task")
      defer {
        vaultLoad.log("end task")
      }
      await model.load()
    }
    .searchable(
      text: $searchString, prompt: String(localized: "Artist or Venue Names", bundle: .module))
  }
}

#Preview {
  SiteView(SiteModel(urlString: "https://www.example.com", error: VaultError.illegalURL("err")))
}

#Preview {
  SiteView(SiteModel(urlString: "https://www.example.com"))
}

#Preview {
  SiteView(
    SiteModel(
      urlString: "https://www.example.com",
      vaultModel: VaultModel(vaultPreviewData, executeAsynchronousTasks: false)))
}
