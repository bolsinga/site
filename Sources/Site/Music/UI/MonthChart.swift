//
//  MonthChart.swift
//
//
//  Created by Greg Bolsinga on 4/29/23.
//

import Charts
import SwiftUI

struct MonthChart: View {
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

  private var format: Date.FormatStyle.Symbol.Month {
    switch presentation {
    case .default:
      horizontalSizeClass == .compact ? .narrow : .abbreviated
    case .compact:
      .narrow
    }
  }

  var body: some View {
    let monthCounts = dates.monthCounts.sorted { $0.key < $1.key }  // array of dictionary elements
    Chart(monthCounts, id: \.key) { item in
      let (date, count) = item.value
      BarMark(
        x: .value("Month", date, unit: .month),
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
      AxisMarks(values: .stride(by: .month)) { _ in
        AxisGridLine()
        AxisTick()
        AxisValueLabel(format: .dateTime.month(format), centered: true)
      }
    }
  }
}

#Preview("Default", traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  MonthChart(dates: Stats(concerts: model.vault.concerts).dates, presentation: .default)
    .padding()
}

#Preview("Compact", traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  MonthChart(dates: Stats(concerts: model.vault.concerts).dates, presentation: .compact)
    .padding()
}
