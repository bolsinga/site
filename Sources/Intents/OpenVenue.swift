//
//  OpenVenue.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

import AppIntents
import Foundation
import os

extension Logger {
  fileprivate static let openVenue = Logger(category: "openVenue")
}

struct OpenVenue: AppIntent {
  static let title = LocalizedStringResource("Open Venue")

  static let description = IntentDescription("Displays Venue Details in App.")

  static var parameterSummary: some ParameterSummary {
    Summary("Open \(\.$target)")
  }

  @Parameter(title: "Venue")
  var target: VenueEntity

  @MainActor func perform() async throws -> some IntentResult & OpensIntent {
    Logger.openVenue.log("Intent Open URL: \(target.url.absoluteString)")
    return .result(opensIntent: OpenURLIntent(target.url))
  }
}
