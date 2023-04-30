//
//  MonthChart.swift
//
//
//  Created by Greg Bolsinga on 4/29/23.
//

import Charts
import SwiftUI

struct MonthChart: View {
  let shows: [Show]

  private var computeMonthShowCounts: [Int: (String, Int)] {  // month as int: (month as string, count of shows for that month)
    let format = Date.FormatStyle.dateTime.month(.abbreviated)
    return shows.filter { !$0.date.isUnknown }.reduce(into: [Int: (String, Int)]()) {
      if let date = $1.date.date {
        let month = Calendar.autoupdatingCurrent.component(.month, from: date)
        let pair = $0[month] ?? (format.format(date), 0)
        $0[month] = (pair.0, pair.1 + 1)
      }
    }
  }

  var body: some View {
    let monthShowCounts = computeMonthShowCounts.sorted { $0.key < $1.key }  // array of dictionary elements
    Chart(monthShowCounts, id: \.key) { item in
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
    MonthChart(shows: [])
  }
}
