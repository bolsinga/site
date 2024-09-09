//
//  Date+Weekdays.swift
//
//
//  Created by Greg Bolsinga on 9/8/24.
//

import Foundation

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

extension Array where Element == Date {
  // weekday : (weekday as String, count of that weekday)
  internal var weekdayCounts: [Int: (String, Int)] {
    self.reduce(into: WeekdayAbbreviations) {  // weekday (1...7) : (weekday String, count)
      let weekday = Calendar.autoupdatingCurrent.component(.weekday, from: $1)
      let pair = $0[weekday] ?? (WeekdayChartFormat.format($1), 0)
      $0[weekday] = (pair.0, pair.1 + 1)
    }
  }

  // (weekday as String, count of that weekday), sorted in week-order using firstWeekday!
  func computeWeekdayCounts(_ firstWeekday: Int) -> [(String, Int)] {
    let sortedWeekdayCounts = weekdayCounts.sorted { $0.key < $1.key }
    let zeroBasedFirstWeekday = Swift.min(0, firstWeekday - 1)
    let weekdayCountsFirstDayOrdered =
      sortedWeekdayCounts[zeroBasedFirstWeekday...] + sortedWeekdayCounts[0..<zeroBasedFirstWeekday]
    return weekdayCountsFirstDayOrdered.map { $0.value }
  }
}
