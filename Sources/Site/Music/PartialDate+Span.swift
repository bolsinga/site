//
//  PartialDate+Span.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import Foundation

extension Sequence<PartialDate> {
  func yearSpan() -> Int {
    let knownYears = self.filter { $0.year != nil }.sorted(by: <)
    if let first = knownYears.first?.year, let last = knownYears.last?.year {
      return abs(last - first) + 1
    }
    return knownYears.count != 0 ? knownYears.count : Set(self.filter { $0.year == nil }).count
  }
}
