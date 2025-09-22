//
//  MonthChart.swift
//
//
//  Created by Greg Bolsinga on 4/29/23.
//

import Charts
import SwiftUI

struct MonthChart: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let dates: [Date]

  private var format: Date.FormatStyle.Symbol.Month {
    horizontalSizeClass == .compact ? .narrow : .abbreviated
  }

  var body: some View {
    let monthCounts = dates.monthCounts.sorted { $0.key < $1.key }  // array of dictionary elements
    Chart(monthCounts, id: \.key) { item in
      BarMark(
        x: .value("Month", item.value.0, unit: .month),
        y: .value("Count", item.value.1)
      )
      .annotation(position: .top) {
        if item.value.1 > 0 {
          Text(item.value.1.formatted(.number))
            .font(.caption2)
        }
      }
    }
    .chartXAxis {
      AxisMarks(values: .stride(by: .month)) { _ in
        AxisGridLine()
        AxisTick()
        AxisValueLabel(format: .dateTime.month(format), centered: true)
      }
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  MonthChart(dates: Stats(concerts: model.vault.concerts).dates)
    .padding()
}
