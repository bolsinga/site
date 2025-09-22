//
//  Date+MonthCounts.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/22/25.
//

import Foundation

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

extension Array where Element == Date {
  var monthCounts: [Int: (String, Int)] {  // month as int: (month as string, count for that month)
    reduce(into: MonthAbbreviations) {
      let month = Calendar.autoupdatingCurrent.component(.month, from: $1)
      let pair = $0[month] ?? (MonthChartFormat.format($1), 0)
      $0[month] = (pair.0, pair.1 + 1)
    }
  }
}
