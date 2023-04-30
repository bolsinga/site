//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import SwiftUI

struct WeekdayChart: View {
  let shows: [Show]

  private var computeWeekdayShowCounts: [Int: (String, Int)] {  // weekday as int: (weekday as string, count of shows on that weekday)
    let format = Date.FormatStyle.dateTime.weekday(.abbreviated)
    return shows.filter { !$0.date.isUnknown }.reduce(into: [Int: (String, Int)]()) {
      if let date = $1.date.date {
        let weekday = Calendar.autoupdatingCurrent.component(.weekday, from: date)
        let pair = $0[weekday] ?? (format.format(date), 0)
        $0[weekday] = (pair.0, pair.1 + 1)
      }
    }
  }

  var body: some View {
    let weekdayShowCounts = computeWeekdayShowCounts.sorted { $0.key < $1.key }  // array of dictionary elements
    Chart(weekdayShowCounts, id: \.key) { item in
      BarMark(
        x: .value(
          Text(
            "Weekday",
            bundle: .module,
            comment: "Label in the chart for the Weekday in WeekdayChart."), item.value.0),
        y: .value(
          Text(
            "Count",
            bundle: .module,
            comment: "Label in the chart for the Count in WeekdayChart."), item.value.1)
      )
      .annotation(position: .top) {
        Text(item.value.1.formatted(.number))
      }
      .cornerRadius(10)
    }
    .frame(minHeight: 200)
    Text("Shows by Day of Week", bundle: .module, comment: "Title of the WeekdayChart")
  }
}

struct WeekdayChart_Previews: PreviewProvider {
  static var previews: some View {
    WeekdayChart(shows: [])
  }
}
