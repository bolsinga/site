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
    .supportedFamilies(Self.families)
  }

  /// iPhone never offers extra large; iPad and Mac do. Accessory families are Lock Screen only,
  /// so they don't exist on macOS.
  private static let families: [WidgetFamily] = {
    var families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    #if os(iOS)
      families.append(contentsOf: [.accessoryRectangular, .accessoryInline])
    #endif
    return families
  }()
}
