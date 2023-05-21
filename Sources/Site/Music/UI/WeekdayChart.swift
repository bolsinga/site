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

  private var computeWeekdayCounts: [Int: (String, Int)] {  // weekday as int: (weekday as string, count of that weekday)
    return dates.reduce(into: WeekdayAbbreviations) {
      let weekday = Calendar.autoupdatingCurrent.component(.weekday, from: $1)
      let pair = $0[weekday] ?? (WeekdayChartFormat.format($1), 0)
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
        if item.value.1 > 0 {
          Text(item.value.1.formatted(.number))
            .font(.caption2)
        }
      }
    }
    .frame(minHeight: 200)
    Text(StatsCategory.weekday.localizedString)
      .font(.caption)
  }
}

struct WeekdayChart_Previews: PreviewProvider {
  static var previews: some View {
    WeekdayChart(dates: [])
  }
}
