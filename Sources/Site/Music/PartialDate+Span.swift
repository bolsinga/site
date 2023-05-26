//
//  PartialDate+Span.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import Foundation

extension Sequence<PartialDate> {
  var yearSpan: Int {
    let uniqueDates = Set(self)
    guard !uniqueDates.isEmpty else { return 0 }
    guard uniqueDates.count > 1 else { return 1 }

    let knownDates = uniqueDates.filter { $0.year != nil }.compactMap { $0.date }.sorted()
    guard knownDates.count > 1 else { return 1 }

    if let max = knownDates.max(), let min = knownDates.min() {
      let comps = Calendar.autoupdatingCurrent.dateComponents([.year], from: min, to: max)
      if let year = comps.year {
        return year
      }
    }

    return knownDates.count
  }
}
