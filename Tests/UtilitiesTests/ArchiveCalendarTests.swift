//
//  ArchiveCalendarTests.swift
//  SiteApp
//

import Foundation
import Testing

@testable import Shared

struct ArchiveCalendarTests {
  /// Reads a date as Gregorian, whatever calendar this machine uses.
  private func components(of date: Date) -> DateComponents {
    var gregorian = Calendar(identifier: .gregorian)
    gregorian.timeZone = Calendar.archive.timeZone
    return gregorian.dateComponents([.year, .month, .day], from: date)
  }

  @Test func archiveIsGregorian() {
    #expect(Calendar.archive.identifier == .gregorian)
  }

  @Test(arguments: [(1996, 2, 29), (2000, 12, 31), (1988, 3, 1), (2025, 2, 28), (1953, 1, 1)])
  func partialDateIsReadAsAGregorianDate(year: Int, month: Int, day: Int) throws {
    let date = try #require(PartialDate(year: year, month: month, day: day).date)
    let read = components(of: date)
    #expect(read.year == year)
    #expect(read.month == month)
    #expect(read.day == day)
  }

  @Test func theLeapDayHasADayOfTheLeapYear() throws {
    let leapDay = try #require(PartialDate(year: 1996, month: 2, day: 29).date)
    #expect(leapDay.dayOfLeapYear == 60)
    let nextDay = try #require(PartialDate(year: 1997, month: 3, day: 1).date)
    #expect(nextDay.dayOfLeapYear == 61)
  }

  @Test func theDayOfTheLeapYearFollowsTheCalendarGiven() throws {
    var losAngeles = Calendar(identifier: .gregorian)
    losAngeles.timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
    var tokyo = losAngeles
    tokyo.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
    // 2027-02-28 20:00 in Los Angeles is 2027-03-01 13:00 in Tokyo.
    let date = try #require(
      DateComponents(calendar: losAngeles, year: 2027, month: 2, day: 28, hour: 20).date)
    #expect(date.dayOfLeapYear(in: losAngeles) == 59)
    #expect(date.dayOfLeapYear(in: tokyo) == 61)
  }

  @Test func yearSpanCountsGregorianYears() {
    let dates: Set<PartialDate> = [
      PartialDate(year: 1996, month: 2, day: 29), PartialDate(year: 2000, month: 2, day: 29),
    ]
    #expect(dates.yearSpan == 4)
  }

  @Test func archiveFormatIgnoresTheCalendarOfALocale() throws {
    let date = try #require(PartialDate(year: 1996, month: 5, day: 1).date)
    let buddhist = Locale(identifier: "en_US@calendar=buddhist")
    #expect(Date.FormatStyle.archiveDateTime.locale(buddhist).year().format(date) == "1996")
  }
}
