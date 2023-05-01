//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import SwiftUI

struct WeekdayChart: View {
  let dates: [Date]

  private var computeWeekdayCounts: [Int: (String, Int)] {  // weekday as int: (weekday as string, count of that weekday)
    let format = Date.FormatStyle.dateTime.weekday(.abbreviated)
    return dates.reduce(into: [Int: (String, Int)]()) {
        let weekday = Calendar.autoupdatingCurrent.component(.weekday, from: $1)
        let pair = $0[weekday] ?? (format.format($1), 0)
        $0[weekday] = (pair.0, pair.1 + 1)
    }
  }

  var body: some View {
    let weekdayCounts = computeWeekdayCounts.sorted { $0.key < $1.key }  // array of dictionary elements
    Chart(weekdayCounts, id: \.key) { item in
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
    WeekdayChart(dates: [])
  }
}
