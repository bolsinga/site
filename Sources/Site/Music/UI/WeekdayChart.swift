//
//  WeekdayChart.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Charts
import SwiftUI

private let WeekdayChartFormat = Date.FormatStyle.dateTime.weekday(.abbreviated)

// weekday as int: (weekday, int) as formatted localized string : count
private var WeekdayAbbreviationsGetter: [Int: (String, Int)] {
  var result = [Int: (String, Int)]()
  let dateComponents = DateComponents(calendar: Calendar.current, year: 2023, month: 4, day: 23)  // start with known Sunday
  var date = dateComponents.date

  for weekday in 1...7 {
    guard date != nil else { fatalError("need to be able to get abbreviated months") }

    result[weekday] = (WeekdayChartFormat.format(date!), 0)

    // go to next day
    date = Calendar.autoupdatingCurrent.date(byAdding: .weekday, value: 1, to: date!)
  }
  return result
}

private let WeekdayAbbreviations = WeekdayAbbreviationsGetter

struct WeekdayChart: View {
  let dates: [Date]

  @State private var firstWeekday = Calendar.autoupdatingCurrent.firstWeekday

  private var computeWeekdayCounts: [(String, Int)] {  // (weekday as String, count of that weekday), sorted in week-order using firstWeekday!
    let weekdayCountMap: [Int: (String, Int)] = dates.reduce(into: WeekdayAbbreviations) { // weekday (1...7) : (weekday String, count)
      let weekday = Calendar.autoupdatingCurrent.component(.weekday, from: $1)
      let pair = $0[weekday] ?? (WeekdayChartFormat.format($1), 0)
      $0[weekday] = (pair.0, pair.1 + 1)
    }
    let sortedWeekdayCounts = weekdayCountMap.sorted { $0.key < $1.key }
    let zeroBasedFirstWeekday = firstWeekday - 1
    let weekdayCountsFirstDayOrdered =
      Array(sortedWeekdayCounts[zeroBasedFirstWeekday...])
      + Array(sortedWeekdayCounts[0..<zeroBasedFirstWeekday])
    return weekdayCountsFirstDayOrdered.map { $0.value }
  }

  var body: some View {
    let weekdayCounts = computeWeekdayCounts
    Chart(weekdayCounts, id: \.0) { item in
      BarMark(
        x: .value(
          Text(
            "Weekday",
            bundle: .module,
            comment: "Label in the chart for the Weekday in WeekdayChart."), item.0),
        y: .value(
          Text(
            "Count",
            bundle: .module,
            comment: "Label in the chart for the Count in WeekdayChart."), item.1)
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
