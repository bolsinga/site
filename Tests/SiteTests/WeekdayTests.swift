//
//  WeekdayTests.swift
//
//
//  Created by Greg Bolsinga on 9/8/24.
//

import XCTest

@testable import Site

final class WeekdayTests: XCTestCase {
  func date(year: Int, month: Int, day: Int) -> Date {
    let dateComponents = DateComponents(
      calendar: Calendar.autoupdatingCurrent, year: year, month: month, day: day)
    return dateComponents.date!
  }

  func testOneSunday() throws {
    let result = [date(year: 2024, month: 9, day: 8)].weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 1)
    XCTAssertEqual(result[2]!.1, 0)
    XCTAssertEqual(result[3]!.1, 0)
    XCTAssertEqual(result[4]!.1, 0)
    XCTAssertEqual(result[5]!.1, 0)
    XCTAssertEqual(result[6]!.1, 0)
    XCTAssertEqual(result[7]!.1, 0)
  }

  func testOneMonday() throws {
    let result = [date(year: 2024, month: 9, day: 9)].weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 0)
    XCTAssertEqual(result[2]!.1, 1)
    XCTAssertEqual(result[3]!.1, 0)
    XCTAssertEqual(result[4]!.1, 0)
    XCTAssertEqual(result[5]!.1, 0)
    XCTAssertEqual(result[6]!.1, 0)
    XCTAssertEqual(result[7]!.1, 0)
  }

  func testOneTuesday() throws {
    let result = [date(year: 2024, month: 9, day: 10)].weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 0)
    XCTAssertEqual(result[2]!.1, 0)
    XCTAssertEqual(result[3]!.1, 1)
    XCTAssertEqual(result[4]!.1, 0)
    XCTAssertEqual(result[5]!.1, 0)
    XCTAssertEqual(result[6]!.1, 0)
    XCTAssertEqual(result[7]!.1, 0)
  }

  func testOneWednesday() throws {
    let result = [date(year: 2024, month: 9, day: 11)].weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 0)
    XCTAssertEqual(result[2]!.1, 0)
    XCTAssertEqual(result[3]!.1, 0)
    XCTAssertEqual(result[4]!.1, 1)
    XCTAssertEqual(result[5]!.1, 0)
    XCTAssertEqual(result[6]!.1, 0)
    XCTAssertEqual(result[7]!.1, 0)
  }

  func testOneThursday() throws {
    let result = [date(year: 2024, month: 9, day: 12)].weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 0)
    XCTAssertEqual(result[2]!.1, 0)
    XCTAssertEqual(result[3]!.1, 0)
    XCTAssertEqual(result[4]!.1, 0)
    XCTAssertEqual(result[5]!.1, 1)
    XCTAssertEqual(result[6]!.1, 0)
    XCTAssertEqual(result[7]!.1, 0)
  }

  func testOneFriday() throws {
    let result = [date(year: 2024, month: 9, day: 13)].weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 0)
    XCTAssertEqual(result[2]!.1, 0)
    XCTAssertEqual(result[3]!.1, 0)
    XCTAssertEqual(result[4]!.1, 0)
    XCTAssertEqual(result[5]!.1, 0)
    XCTAssertEqual(result[6]!.1, 1)
    XCTAssertEqual(result[7]!.1, 0)
  }

  func testOneSaturday() throws {
    let result = [date(year: 2024, month: 9, day: 14)].weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 0)
    XCTAssertEqual(result[2]!.1, 0)
    XCTAssertEqual(result[3]!.1, 0)
    XCTAssertEqual(result[4]!.1, 0)
    XCTAssertEqual(result[5]!.1, 0)
    XCTAssertEqual(result[6]!.1, 0)
    XCTAssertEqual(result[7]!.1, 1)
  }

  func testTwoMonday() throws {
    let result = [date(year: 2024, month: 9, day: 9), date(year: 2024, month: 9, day: 16)]
      .weekdayCounts
    XCTAssertEqual(result.count, 7)
    XCTAssertNil(result[0])
    XCTAssertEqual(result[1]!.1, 0)
    XCTAssertEqual(result[2]!.1, 2)
    XCTAssertEqual(result[3]!.1, 0)
    XCTAssertEqual(result[4]!.1, 0)
    XCTAssertEqual(result[5]!.1, 0)
    XCTAssertEqual(result[6]!.1, 0)
    XCTAssertEqual(result[7]!.1, 0)
  }

  //  func testOneSunday_first_invalid_0() throws {
  //    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(0)
  //    XCTAssertEqual(result.count, 7)
  //    XCTAssertEqual(result[0].0, "Sun")
  //    XCTAssertEqual(result[0].1, 1)
  //    XCTAssertEqual(result[1].1, 0)
  //    XCTAssertEqual(result[2].1, 0)
  //    XCTAssertEqual(result[3].1, 0)
  //    XCTAssertEqual(result[4].1, 0)
  //    XCTAssertEqual(result[5].1, 0)
  //    XCTAssertEqual(result[6].1, 0)
  //  }

  func testOneSunday_first_1() throws {
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(1)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }

  func testOneSunday_first_2() throws {
    // This is incorrect.
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(2)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }

  func testOneSunday_first_3() throws {
    // This is incorrect.
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(3)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }

  func testOneSunday_first_4() throws {
    // This is incorrect.
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(4)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }

  func testOneSunday_first_5() throws {
    // This is incorrect.
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(5)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }

  func testOneSunday_first_6() throws {
    // This is incorrect.
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(6)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }

  func testOneSunday_first_7() throws {
    // This is incorrect.
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(7)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }

  func testOneSunday_first_invalid_8() throws {
    // This is incorrect.
    let result = [date(year: 2024, month: 9, day: 8)].computeWeekdayCounts(8)
    XCTAssertEqual(result.count, 7)
    XCTAssertEqual(result[0].0, "Sun")
    XCTAssertEqual(result[0].1, 1)
    XCTAssertEqual(result[1].1, 0)
    XCTAssertEqual(result[2].1, 0)
    XCTAssertEqual(result[3].1, 0)
    XCTAssertEqual(result[4].1, 0)
    XCTAssertEqual(result[5].1, 0)
    XCTAssertEqual(result[6].1, 0)
  }
}
