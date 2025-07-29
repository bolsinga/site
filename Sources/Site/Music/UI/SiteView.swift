//
//  SiteView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI
import os

#if swift(>=6.2) || !targetEnvironment(simulator)
  extension Logger {
    fileprivate static let vaultLoad = Logger(category: "vaultLoad")
  }
#else
  struct PreviewLoggerWorkaround {
    func log(_ string: String) {}
  }
#endif

public struct SiteView: View {
  private let model: SiteModel
  #if swift(>=6.2) || !targetEnvironment(simulator)
    private let logger: Logger? = Logger.vaultLoad
  #else
    private let logger: PreviewLoggerWorkaround? = PreviewLoggerWorkaround()
  #endif

  public init(_ model: SiteModel) {
    self.model = model
  }

  public var body: some View {
    Group {
      if let vaultModel = model.vaultModel {
        ArchiveStateView()
          .environment(vaultModel)
          .refreshable {
            logger?.log("start refresh")
            defer {
              logger?.log("end refresh")
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
              logger?.log("User retry")
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

      logger?.log("start task")
      defer {
        logger?.log("end task")
      }
      await model.load()
    }
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
