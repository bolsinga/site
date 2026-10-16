//
//  SiteView.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import Shared
import SwiftUI
import os

extension Logger {
  fileprivate static let siteView = Logger(category: "siteView")
}

public struct SiteView: View {
  @AppStorage("music.last.modified") private var musicLastModified: Date = .distantPast
  private let model: SiteModel

  @State private var pendingExternalEvent: ExternalEvent?

  public init(_ model: SiteModel) {
    self.model = model
  }

  public var body: some View {
    Group {
      if let vaultModel = model.vaultModel {
        ArchiveStateView(pendingExternalEvent: $pendingExternalEvent) {
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

      await model.load(.initial(musicLastModified))
    }
    .onChange(of: model.lastModified) { _, newValue in
      musicLastModified = newValue
    }
    .onContinueUserActivity(ArchivePath.activityType) {
      Logger.siteView.log("onContinueUserActivity ArchivePath")
      pendingExternalEvent = ExternalEvent(kind: .path($0))
    }
    .onContinueUserActivity(ArchiveCategory.activityType) {
      Logger.siteView.log("onContinueUserActivity ArchiveCategory")
      pendingExternalEvent = ExternalEvent(kind: .category($0))
    }
    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) {
      Logger.siteView.log(
        "onContinueUserActivity browsingWeb: \(String(describing: $0.webpageURL), privacy: .public)"
      )
      if let url = $0.webpageURL {
        pendingExternalEvent = ExternalEvent(kind: .url(url))
      }
    }
    .onOpenURL {
      Logger.siteView.log("onOpenURL: \($0.absoluteString, privacy: .public)")
      pendingExternalEvent = ExternalEvent(kind: .url($0))
    }
    #if !os(tvOS)
      .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
    #endif
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
