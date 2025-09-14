//
//  OpenVenue.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/10/25.
//

import AppIntents
import Foundation

struct OpenVenue: OpenIntent, URLRepresentableIntent {
  static let title = LocalizedStringResource("Open Venue")

  static let description = IntentDescription("Displays Venue Details in App.")

  static var parameterSummary: some ParameterSummary {
    Summary("Open \(\.$target)")
  }

  @Parameter(title: "Venue")
  var target: VenueEntity
}
