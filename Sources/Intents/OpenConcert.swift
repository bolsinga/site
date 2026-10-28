//
//  OpenConcert.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/12/25.
//

import AppIntents
import Foundation
import Shared

struct OpenConcert: OpenIntent, URLRepresentableIntent {
  static let title = LocalizedStringResource("Open Concert")

  static let description = IntentDescription("Displays Concert Details in App.")

  static var parameterSummary: some ParameterSummary {
    Summary("Open \(\.$target)")
  }

  @Parameter(title: "Concert")
  var target: ConcertEntity
}
