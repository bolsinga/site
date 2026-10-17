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

  /// The day's shows with the featured one first. Random keeps the rest oldest first.
  func arrange(_ shows: [ShowDigest]) -> [ShowDigest] {
    switch self {
    case .oldest:
      return shows.sorted()
    case .newest:
      return shows.sorted(by: >)
    case .random:
      guard let featured = shows.randomElement() else { return [] }
      return [featured] + shows.sorted().filter { $0 != featured }
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
