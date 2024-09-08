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

  @State private var firstWeekday = Calendar.autoupdatingCurrent.firstWeekday

  var body: some View {
    let weekdayCounts = dates.computeWeekdayCounts(firstWeekday)
    Chart(weekdayCounts, id: \.0) { item in
      BarMark(
        x: .value(Text("Weekday", bundle: .module), item.0),
        y: .value(Text("Count", bundle: .module), item.1)
      )
      .annotation(position: .top) {
        if item.1 > 0 {
          Text(item.1.formatted(.number))
            .font(.caption2)
        }
      }
    }
    .onNotification(name: NSLocale.currentLocaleDidChangeNotification) {
      firstWeekday = Calendar.current.firstWeekday
    }
  }
}
