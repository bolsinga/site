//
//  DayMonthTests.swift
//  Tests
//
//  Created by Greg Bolsinga on 10/20/25.
//

import Foundation
import Testing

@testable import SiteApp

struct DayMonthTests {
  private func date(year: Int, month: Int, day: Int) -> Date {
    let dateComponents = DateComponents(
      calendar: Calendar.autoupdatingCurrent, year: year, month: month, day: day)
    return dateComponents.date!
  }

  @Test func halloween() async throws {
    let halloween = date(year: 2025, month: 10, day: 31)
    #expect(halloween.dayMonth == 1031)
  }

  @Test func halloweenLeapYear() async throws {
    let halloween = date(year: 2024, month: 10, day: 31)
    #expect(halloween.dayMonth == 1031)
  }
}
