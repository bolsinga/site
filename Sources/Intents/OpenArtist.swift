//
//  OpenArtist.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import AppIntents
import Foundation

struct OpenArtist: OpenIntent, URLRepresentableIntent {
  static let title = LocalizedStringResource("Open Artist")

  static let description = IntentDescription("Displays Artist Details in App.")

  static var parameterSummary: some ParameterSummary {
    Summary("Open \(\.$target)")
  }

  @Parameter(title: "Artist")
  var target: ArtistEntity
}
