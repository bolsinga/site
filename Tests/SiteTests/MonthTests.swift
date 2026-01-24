//
//  MonthTests.swift
//  Tests
//
//  Created by Greg Bolsinga on 9/29/25.
//

import Foundation
import Testing

@testable import SiteApp

private func date(year: Int, month: Int, day: Int) -> Date {
  let dateComponents = DateComponents(
    calendar: .autoupdatingCurrent, year: year, month: month, day: day)
  return dateComponents.date!
}

struct MonthTests {
  let dates = [
    date(year: 2025, month: 8, day: 28), date(year: 2025, month: 9, day: 29),
    date(year: 2026, month: 5, day: 29), date(year: 2026, month: 5, day: 30),
  ]

  let multipleTops = [
    date(year: 2025, month: 8, day: 28), date(year: 2025, month: 8, day: 29),
    date(year: 2026, month: 5, day: 29), date(year: 2026, month: 5, day: 30),
  ]

  @Test func basic() async throws {
    let r = dates.monthCounts

    #expect(r.count == 12)  // One for each month.

    #expect(r.filter { $0.value.1 > 0 }.count == 3)  // Three months available.
  }

  @Test func topDate() async throws {
    #expect(dates.monthCounts.map { $0 }.topDate != nil)
  }

  @Test func noTopDate() async throws {
    #expect(multipleTops.monthCounts.map { $0 }.topDate == nil)
  }
}
