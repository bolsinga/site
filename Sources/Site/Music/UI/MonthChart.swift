//
//  MonthChart.swift
//
//
//  Created by Greg Bolsinga on 4/29/23.
//

import Charts
import SwiftUI

private let MonthChartFormat = Date.FormatStyle.dateTime.month(.abbreviated)

// month as int: month as formatted localized string
private var MonthAbbreviationsGetter: [Int: (String, Int)] {
  var result = [Int: (String, Int)]()
  for month in 1...12 {
    guard
      let date = DateComponents(calendar: Calendar.current, year: 2023, month: month, day: 1).date
    else { fatalError("need to be able to get abbreviated months") }
    result[month] = (MonthChartFormat.format(date), 0)
  }
  return result
}

private let MonthAbbreviations = MonthAbbreviationsGetter

struct MonthChart: View {
  let dates: [Date]

  private var computeMonthCounts: [Int: (String, Int)] {  // month as int: (month as string, count for that month)
    return dates.reduce(into: MonthAbbreviations) {
      let month = Calendar.autoupdatingCurrent.component(.month, from: $1)
      let pair = $0[month] ?? (MonthChartFormat.format($1), 0)
      $0[month] = (pair.0, pair.1 + 1)
    }
  }

  var body: some View {
    let monthCounts = computeMonthCounts.sorted { $0.key < $1.key }  // array of dictionary elements
    Chart(monthCounts, id: \.key) { item in
      BarMark(
        x: .value(
          Text(
            "Month",
            bundle: .module,
            comment: "Label in the chart for the Month in MonthChart."), item.value.0),
        y: .value(
          Text(
            "Count",
            bundle: .module,
            comment: "Label in the chart for the Count in MonthChart."), item.value.1)
      )
      .annotation(position: .top) {
        if item.value.1 > 0 {
          Text(item.value.1.formatted(.number))
            .font(.caption2)
        }
      }
    }
    .frame(minHeight: 200)
    Text(StatsCategory.month.localizedString)
      .font(.caption)
  }
}

struct MonthChart_Previews: PreviewProvider {
  static var previews: some View {
    MonthChart(dates: [])
  }
}
