//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import SwiftUI

struct WeekdayChart: View {
  enum Presentation {
    case `default`
    case compact
  }

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let dates: [Date]
  let presentation: Presentation

  internal init(dates: [Date], presentation: Presentation = .default) {
    self.dates = dates
    self.presentation = presentation
  }

  private var format: Date.FormatStyle.Symbol.Weekday {
    switch presentation {
    case .default:
      horizontalSizeClass == .compact ? .narrow : .abbreviated
    case .compact:
      .narrow
    }
  }

  @State private var firstWeekday = Calendar.autoupdatingCurrent.firstWeekday

  var body: some View {
    let weekdayCounts = dates.computeWeekdayCounts(firstWeekday)
    Chart(weekdayCounts, id: \.0) { item in
      let (date, count) = item.1
      BarMark(
        x: .value("Weekday", date, unit: .day),
        y: .value("Count", count)
      )
      .annotation(position: .top) {
        if count > 0, presentation == .default {
          Text(count.formatted(.number))
            .font(.caption2)
        }
      }
    }
    .chartYAxis(presentation == .compact ? .hidden : .automatic)
    .chartXAxis {
      AxisMarks(values: .stride(by: .day)) { _ in
        AxisGridLine()
        AxisTick()
        AxisValueLabel(format: .dateTime.weekday(format), centered: true)
      }
    }
    .onNotification(name: NSLocale.currentLocaleDidChangeNotification) {
      firstWeekday = Calendar.current.firstWeekday
    }
  }
}

#Preview("Default", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(dates: Stats(concerts: model.vault.concerts).dates, presentation: .default)
    .padding()
}

#Preview("Compact", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(dates: Stats(concerts: model.vault.concerts).dates, presentation: .compact)
    .padding()
}
