//
//  Date+Weekdays.swift
//
//
//  Created by Greg Bolsinga on 9/8/24.
//

import Foundation

// weekday as int: (weekday, int) as Date : count
private var weekdayAbbreviations: [Int: (Date, Int)] {
  var result = [Int: (Date, Int)]()
  let dateComponents = DateComponents(calendar: Calendar.current, year: 2023, month: 4, day: 23)  // start with known Sunday
  var date = dateComponents.date

  for weekday in 1...7 {
    guard date != nil else { fatalError("need to be able to get abbreviated months") }

    result[weekday] = (date!, 0)

    // go to next day
    date = Calendar.autoupdatingCurrent.date(byAdding: .weekday, value: 1, to: date!)
  }
  return result
}

extension Array where Element == Date {
  // weekday : (weekday represented as Date, count of that weekday)
  internal var weekdayCounts: [Int: (Date, Int)] {
    self.reduce(into: weekdayAbbreviations) {  // weekday (1...7) : (weekday Date, count)
      let weekday = Calendar.autoupdatingCurrent.component(.weekday, from: $1)
      let pair = $0[weekday] ?? ($1, 0)
      $0[weekday] = (pair.0, pair.1 + 1)
    }
  }

  // weekday as int: (month as Date, count for that month)
  func computeWeekdayCounts(_ firstWeekday: Int) -> [(Int, (Date, Int))] {
    let sortedWeekdayCounts = weekdayCounts.sorted { $0.key < $1.key }
    let zeroBasedFirstWeekday = Swift.min(6, Swift.max(0, firstWeekday - 1))
    let weekdayCountsFirstDayOrdered =
      sortedWeekdayCounts[zeroBasedFirstWeekday...] + sortedWeekdayCounts[0..<zeroBasedFirstWeekday]
    return weekdayCountsFirstDayOrdered.map { ($0.key, $0.value) }
  }
}
