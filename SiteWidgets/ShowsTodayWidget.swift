//
//  ShowsTodayWidget.swift
//  SiteWidgets
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Shared
import SwiftUI
import WidgetKit

struct ShowsTodayWidget: Widget {
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: ShowsTodayWidgetKind.kind, intent: ShowsTodayConfiguration.self,
      provider: ShowsTodayProvider()
    ) { entry in
      ShowsTodayWidgetView(entry: entry)
    }
    .configurationDisplayName("Shows Today")
    .description("See which shows happened today across the archive's history.")
    .supportedFamilies([.systemSmall])
  }
}
