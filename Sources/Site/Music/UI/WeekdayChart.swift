//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import SwiftUI

struct WeekdayChart: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let dates: [Date]

  private var format: Date.FormatStyle.Symbol.Weekday {
    horizontalSizeClass == .compact ? .narrow : .abbreviated
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
        if count > 0 {
          Text(count.formatted(.number))
            .font(.caption2)
        }
      }
    }
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

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  WeekdayChart(dates: Stats(concerts: model.vault.concerts).dates)
    .padding()
}
