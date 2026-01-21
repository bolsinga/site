//
//  PartialDate+Span.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import Foundation

private let spanComponents = Set([
  Calendar.Component.year, Calendar.Component.month, Calendar.Component.day,
])

extension Set<PartialDate> {
  public var yearSpan: Int {
    guard !isEmpty else { return 0 }
    guard count > 1 else { return 1 }

    let knownDates = filter { $0.year != nil }.compactMap { $0.date }.sorted()
    guard knownDates.count > 1 else { return 1 }

    if let max = knownDates.max(), let min = knownDates.min() {
      let comps = Calendar.autoupdatingCurrent.dateComponents(spanComponents, from: min, to: max)
      if let year = comps.year, let month = comps.month, let day = comps.day {
        guard year > 0 else { return 1 }  // It's less than a year difference, so the sequence spans 1 year.
        guard year == 1 else { return year }  // It's more than 1 year, so just count the years, no rounding. Matches RelativeDateTimeFormatter() output.
        return year + (month > 0 ? 1 : (day > 0 ? 1 : 0))  // It's 1 year and some time.
      }
    }

    return knownDates.count
  }
}
