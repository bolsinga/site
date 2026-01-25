//
//  Date+MonthCounts.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/22/25.
//

import Foundation

// month as int: (month as Date, count for that month)
private var monthAbbreviations: [Int: (Date, Int)] {
  var result = [Int: (Date, Int)]()
  for month in 1...12 {
    guard
      let date = DateComponents(calendar: .autoupdatingCurrent, year: 2023, month: month, day: 1)
        .date
    else { fatalError("need to be able to get abbreviated months") }
    result[month] = (date, 0)
  }
  return result
}

extension Array where Element == Date {
  // month as int: (month as Date, count for that month)
  var monthCounts: [Int: (Date, Int)] {
    reduce(into: monthAbbreviations) {
      let month = Calendar.autoupdatingCurrent.component(.month, from: $1)
      let pair = $0[month] ?? ($1, 0)
      $0[month] = (pair.0, pair.1 + 1)
    }
  }
}
