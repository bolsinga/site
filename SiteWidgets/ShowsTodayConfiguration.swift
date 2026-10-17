//
//  ShowsTodayConfiguration.swift
//  SiteWidgets
//
//  Created by Greg Bolsinga on 10/16/26.
//

import AppIntents
import Shared
import WidgetKit

/// Raw values are persisted in people's widget configurations; never rename or remove them.
enum ShowsTodayOrder: String, AppEnum {
  case oldest
  case newest
  case random

  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Order"

  static let caseDisplayRepresentations: [ShowsTodayOrder: DisplayRepresentation] = [
    .oldest: "Oldest",
    .newest: "Newest",
    .random: "Random",
  ]

  func pick(from shows: [ShowDigest]) -> ShowDigest? {
    switch self {
    case .oldest:
      shows.min()
    case .newest:
      shows.max()
    case .random:
      shows.randomElement()
    }
  }
}

struct ShowsTodayConfiguration: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Shows Today"
  static let description = IntentDescription("Choose which of today's shows to feature.")

  @Parameter(title: "Show", default: .oldest)
  var order: ShowsTodayOrder

  init() {}

  init(order: ShowsTodayOrder) {
    self.order = order
  }
}
