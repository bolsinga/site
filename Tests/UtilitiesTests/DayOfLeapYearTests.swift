//
//  DayOfLeapYearTests.swift
//  Tests
//
//  Created by Greg Bolsinga on 10/20/25.
//

import Foundation
import Testing

@testable import SiteApp

extension Date {
  fileprivate var dayOfYear: Int {
    Calendar.autoupdatingCurrent.component(.dayOfYear, from: self)
  }

  fileprivate var month: Int {
    Calendar.autoupdatingCurrent.component(.month, from: self)
  }

  fileprivate var day: Int {
    Calendar.autoupdatingCurrent.component(.day, from: self)
  }
}

struct DayOfLeapYearTests {
  private func date(year: Int, month: Int, day: Int) -> Date {
    let dateComponents = DateComponents(
      calendar: Calendar.autoupdatingCurrent, year: year, month: month, day: day)
    return dateComponents.date!
  }

  @Test func lastDayFebruary() async throws {
    let lastDay = date(year: 2025, month: 2, day: 28)
    #expect(lastDay.dayOfYear == 59)
    #expect(lastDay.dayOfLeapYear == 59)

    let nextDay = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: lastDay)!
    #expect(nextDay.month == 3)
    #expect(nextDay.day == 1)
    #expect(nextDay.dayOfYear == 60)
    #expect(nextDay.dayOfLeapYear == 61)
  }

  @Test func lastDayFebruaryLeapYear() async throws {
    let lastDay = date(year: 2024, month: 2, day: 28)
    #expect(lastDay.dayOfYear == 59)
    #expect(lastDay.dayOfLeapYear == 59)

    var nextDay = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: lastDay)!
    #expect(nextDay.month == 2)
    #expect(nextDay.day == 29)
    #expect(nextDay.dayOfYear == 60)
    #expect(nextDay.dayOfLeapYear == 60)

    nextDay = Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: nextDay)!
    #expect(nextDay.month == 3)
    #expect(nextDay.day == 1)
    #expect(nextDay.dayOfYear == 61)
    #expect(nextDay.dayOfLeapYear == 61)
  }

  @Test func halloween() async throws {
    let halloween = date(year: 2025, month: 10, day: 31)
    #expect(halloween.dayOfYear == 304)
    #expect(halloween.dayOfLeapYear == 305)
  }

  @Test func halloweenLeapYear() async throws {
    let halloween = date(year: 2024, month: 10, day: 31)
    #expect(halloween.dayOfYear == 305)
    #expect(halloween.dayOfLeapYear == 305)
  }

  @Test func invalidDayOfLeapYearFormatted() async throws {
    #expect((-1).dayOfLeapYearFormatted == "")
    #expect(0.dayOfLeapYearFormatted == "")
    #expect(367.dayOfLeapYearFormatted == "")
  }

  @Test func validDayOfLeapYearFormatted() async throws {
    #expect(1.dayOfLeapYearFormatted == "1/1")
    #expect(59.dayOfLeapYearFormatted == "2/28")
    #expect(60.dayOfLeapYearFormatted == "2/29")
    #expect(61.dayOfLeapYearFormatted == "3/1")
    #expect(366.dayOfLeapYearFormatted == "12/31")
  }
}
