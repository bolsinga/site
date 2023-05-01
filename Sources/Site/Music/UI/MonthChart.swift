//
//  MonthChart.swift
//
//
//  Created by Greg Bolsinga on 4/29/23.
//

import Charts
import SwiftUI

private let MonthChartFormat = Date.FormatStyle.dateTime.month(.abbreviated)

struct MonthChart: View {
  let dates: [Date]

  private var computeMonthCounts: [Int: (String, Int)] {  // month as int: (month as string, count for that month)
    return dates.reduce(into: [Int: (String, Int)]()) {
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
        Text(item.value.1.formatted(.number))
      }
      .cornerRadius(10)
    }
    .frame(minHeight: 200)
    Text("Shows by Month", bundle: .module, comment: "Title of the MonthChart")
  }
}

struct MonthChart_Previews: PreviewProvider {
  static var previews: some View {
    MonthChart(dates: [])
  }
}
