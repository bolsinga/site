//
//  WeekdayTests.swift
//
//
//  Created by Greg Bolsinga on 9/8/24.
//

import Foundation
import Testing

@testable import SiteApp

private func date(year: Int, month: Int, day: Int) -> Date {
  let dateComponents = DateComponents(
    calendar: .autoupdatingCurrent, year: year, month: month, day: day)
  return dateComponents.date!
}

struct WeekdayTests {
  @Test func oneSunday() {
    let result = [date(year: 2024, month: 9, day: 8)].weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 1)
    #expect(result[2]!.1 == 0)
    #expect(result[3]!.1 == 0)
    #expect(result[4]!.1 == 0)
    #expect(result[5]!.1 == 0)
    #expect(result[6]!.1 == 0)
    #expect(result[7]!.1 == 0)
  }

  @Test func oneMonday() {
    let result = [date(year: 2024, month: 9, day: 9)].weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 0)
    #expect(result[2]!.1 == 1)
    #expect(result[3]!.1 == 0)
    #expect(result[4]!.1 == 0)
    #expect(result[5]!.1 == 0)
    #expect(result[6]!.1 == 0)
    #expect(result[7]!.1 == 0)
  }

  @Test func oneTuesday() {
    let result = [date(year: 2024, month: 9, day: 10)].weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 0)
    #expect(result[2]!.1 == 0)
    #expect(result[3]!.1 == 1)
    #expect(result[4]!.1 == 0)
    #expect(result[5]!.1 == 0)
    #expect(result[6]!.1 == 0)
    #expect(result[7]!.1 == 0)
  }

  @Test func oneWednesday() {
    let result = [date(year: 2024, month: 9, day: 11)].weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 0)
    #expect(result[2]!.1 == 0)
    #expect(result[3]!.1 == 0)
    #expect(result[4]!.1 == 1)
    #expect(result[5]!.1 == 0)
    #expect(result[6]!.1 == 0)
    #expect(result[7]!.1 == 0)
  }

  @Test func oneThursday() {
    let result = [date(year: 2024, month: 9, day: 12)].weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 0)
    #expect(result[2]!.1 == 0)
    #expect(result[3]!.1 == 0)
    #expect(result[4]!.1 == 0)
    #expect(result[5]!.1 == 1)
    #expect(result[6]!.1 == 0)
    #expect(result[7]!.1 == 0)
  }

  @Test func oneFriday() {
    let result = [date(year: 2024, month: 9, day: 13)].weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 0)
    #expect(result[2]!.1 == 0)
    #expect(result[3]!.1 == 0)
    #expect(result[4]!.1 == 0)
    #expect(result[5]!.1 == 0)
    #expect(result[6]!.1 == 1)
    #expect(result[7]!.1 == 0)
  }

  @Test func oneSaturday() {
    let result = [date(year: 2024, month: 9, day: 14)].weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 0)
    #expect(result[2]!.1 == 0)
    #expect(result[3]!.1 == 0)
    #expect(result[4]!.1 == 0)
    #expect(result[5]!.1 == 0)
    #expect(result[6]!.1 == 0)
    #expect(result[7]!.1 == 1)
  }

  @Test func twoMonday() {
    let result = [date(year: 2024, month: 9, day: 9), date(year: 2024, month: 9, day: 16)]
      .weekdayCounts
    #expect(result.count == 7)
    #expect(result[0] == nil)
    #expect(result[1]!.1 == 0)
    #expect(result[2]!.1 == 2)
    #expect(result[3]!.1 == 0)
    #expect(result[4]!.1 == 0)
    #expect(result[5]!.1 == 0)
    #expect(result[6]!.1 == 0)
    #expect(result[7]!.1 == 0)
  }

  @Test func oneSunday_first_invalid_0() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(0)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Sun")
    #expect(result[0].1.1 == 1)
    #expect(result[1].1.1 == 0)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 0)
  }

  @Test func oneSunday_first_1() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(1)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Sun")
    #expect(result[0].1.1 == 1)
    #expect(result[1].1.1 == 0)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 0)
  }

  @Test func oneSunday_first_2() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(2)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Mon")
    #expect(result[0].1.1 == 0)
    #expect(result[1].1.1 == 0)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 1)
  }

  @Test func oneSunday_first_3() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(3)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Tue")
    #expect(result[0].1.1 == 0)
    #expect(result[1].1.1 == 0)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 1)
    #expect(result[6].1.1 == 0)
  }

  @Test func oneSunday_first_4() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(4)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Wed")
    #expect(result[0].1.1 == 0)
    #expect(result[1].1.1 == 0)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 1)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 0)
  }

  @Test func oneSunday_first_5() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(5)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Thu")
    #expect(result[0].1.1 == 0)
    #expect(result[1].1.1 == 0)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 1)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 0)
  }

  @Test func oneSunday_first_6() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(6)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Fri")
    #expect(result[0].1.1 == 0)
    #expect(result[1].1.1 == 0)
    #expect(result[2].1.1 == 1)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 0)
  }

  @Test func oneSunday_first_7() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(7)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Sat")
    #expect(result[0].1.1 == 0)
    #expect(result[1].1.1 == 1)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 0)
  }

  @Test func oneSunday_first_invalid_8() {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(8)
    #expect(result.count == 7)
    #expect(Date.FormatStyle.dateTime.weekday(.abbreviated).format(result[0].1.0) == "Sat")
    #expect(result[0].1.1 == 0)
    #expect(result[1].1.1 == 1)
    #expect(result[2].1.1 == 0)
    #expect(result[3].1.1 == 0)
    #expect(result[4].1.1 == 0)
    #expect(result[5].1.1 == 0)
    #expect(result[6].1.1 == 0)
  }

  let dates = [
    date(year: 2025, month: 8, day: 1), date(year: 2025, month: 8, day: 8),
    date(year: 2025, month: 8, day: 3), date(year: 2025, month: 8, day: 4),
  ]

  let multipleTops = [
    date(year: 2025, month: 8, day: 1), date(year: 2025, month: 8, day: 8),
    date(year: 2025, month: 8, day: 3), date(year: 2025, month: 8, day: 10),
  ]

  @Test func basic() async throws {
    let r = dates.weekdayCounts

    #expect(r.count == 7)  // One for each weekday.

    #expect(r.filter { $0.value.1 > 0 }.count == 3)  // Three weekdays available.
  }

  @Test func topDate() async throws {
    #expect(dates.weekdayCounts.map { $0 }.topDate != nil)
  }

  @Test func noTopDate() async throws {
    #expect(multipleTops.weekdayCounts.map { $0 }.topDate == nil)
  }
}
