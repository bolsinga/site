//
//  OpenArtist.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import AppIntents
import Foundation
import os

extension Logger {
  fileprivate static let openArtist = Logger(category: "openArtist")
}

struct OpenArtist: AppIntent {
  static let title = LocalizedStringResource("Open Artist")

  static let description = IntentDescription("Displays Artist Details in App.")

  static var parameterSummary: some ParameterSummary {
    Summary("Open \(\.$target)")
  }

  @Parameter(title: "Artist")
  var target: ArtistEntity

  @MainActor func perform() async throws -> some IntentResult & OpensIntent {
    Logger.openArtist.log("Intent Open URL: \(target.url.absoluteString)")
    return .result(opensIntent: OpenURLIntent(target.url))
  }
}
