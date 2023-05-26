//
//  PartialDateTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import XCTest

@testable import Site

final class PartialDateTests: XCTestCase {
  func testUnknown_Unknown() throws {
    let unknown1 = PartialDate()
    let unknown2 = PartialDate()

    XCTAssertEqual(unknown1, unknown2)
    XCTAssertFalse(unknown1 < unknown2)
    XCTAssertFalse(unknown2 < unknown1)
  }

  func testUnknown_YearOnly() throws {
    let unknown = PartialDate()
    let yearOnly = PartialDate(year: 1997)

    XCTAssertNotEqual(unknown, yearOnly)
    XCTAssertTrue(unknown < yearOnly)
    XCTAssertFalse(yearOnly < unknown)
  }

  func testUnknown_fullDate() throws {
    let unknown = PartialDate()
    let date = PartialDate(year: 1970, month: 10, day: 31)

    XCTAssertNotEqual(unknown, date)
    XCTAssertTrue(unknown < date)
    XCTAssertFalse(date < unknown)
  }

  func testYearOnly_YearOnly_sameYear() throws {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1997)

    XCTAssertEqual(date1, date2)
    XCTAssertFalse(date1 < date2)
    XCTAssertFalse(date2 < date1)
  }

  func testYearOnly_YearOnly_differentYear() throws {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1998)

    XCTAssertNotEqual(date1, date2)
    XCTAssertTrue(date1 < date2)
    XCTAssertFalse(date2 < date1)
  }

  func testYearOnly_fullDate_sameYear() throws {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1997, month: 12, day: 31)

    XCTAssertNotEqual(date1, date2)
    XCTAssertTrue(date1 < date2)
    XCTAssertFalse(date2 < date1)
  }

  func testYearOnly_fullDate_nextYear() throws {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1998, month: 12, day: 31)

    XCTAssertNotEqual(date1, date2)
    XCTAssertTrue(date1 < date2)
    XCTAssertFalse(date2 < date1)
  }

  func testYearOnly_fullDate_previousYear() throws {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1996, month: 12, day: 31)

    XCTAssertNotEqual(date1, date2)
    XCTAssertFalse(date1 < date2)
    XCTAssertTrue(date2 < date1)
  }

  func testFullDate_FullDate() throws {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1996, month: 12, day: 31)

    XCTAssertNotEqual(date1, date2)
    XCTAssertTrue(date1 < date2)
    XCTAssertFalse(date2 < date1)
  }

  func testFullDate_FullDate_same() throws {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1995, month: 12, day: 31)

    XCTAssertEqual(date1, date2)
    XCTAssertFalse(date1 < date2)
    XCTAssertFalse(date2 < date1)
  }

  func testFormat() throws {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1997)
    let unknownDate = PartialDate()

    XCTAssertEqual(date1.formatted(), "12/31/1995")
    XCTAssertEqual(date2.formatted(), "1997")
    XCTAssertEqual(unknownDate.formatted(), "Date Unknown")

    XCTAssertEqual(date1.formatted(.compact), "12/31/1995")
    XCTAssertEqual(date2.formatted(.compact), "1997")
    XCTAssertEqual(unknownDate.formatted(.compact), "Date Unknown")

    XCTAssertEqual(date1.formatted(.yearOnly), "1995")
    XCTAssertEqual(date2.formatted(.yearOnly), "1997")
    XCTAssertEqual(unknownDate.formatted(.yearOnly), "Year Unknown")

    XCTAssertEqual(date1.formatted(.noYear), "December 31")
    XCTAssertEqual(date2.formatted(.noYear), "1997")
    XCTAssertEqual(unknownDate.formatted(.noYear), "Date Unknown")
  }

  func testSpans() throws {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1997)
    let unknownDate = PartialDate()

    XCTAssertEqual([date1].yearSpan, 1)
    XCTAssertEqual([date2].yearSpan, 1)
    XCTAssertEqual([unknownDate].yearSpan, 1)

    XCTAssertEqual([date1, date2].yearSpan, 2)
    XCTAssertEqual([date1, date1].yearSpan, 1)
    XCTAssertEqual([date2, date2].yearSpan, 1)

    XCTAssertEqual([unknownDate, unknownDate].yearSpan, 1)
    XCTAssertEqual([unknownDate, date1].yearSpan, 1)
    XCTAssertEqual([unknownDate, date1, date2].yearSpan, 2)

    XCTAssertEqual([PartialDate]().yearSpan, 0)

    let unwoundDate = PartialDate(year: 1995, month: 4, day: 1)
    let unwoundDate28YearsAgo = PartialDate(year: 2023, month: 5, day: 26)
    XCTAssertEqual([unwoundDate, unwoundDate28YearsAgo].yearSpan, 28)

    let unwoundLast = PartialDate(year: 2023, month: 2, day: 8)
    XCTAssertEqual([unwoundDate, unwoundLast].yearSpan, 27)

    let miloFirst = PartialDate(year: 1993, month: 2, day: 13)
    let miloLast = PartialDate(year: 1994, month: 5, day: 13)
    XCTAssertEqual([miloFirst, miloLast].yearSpan, 2)

    let jumpknuckleFirst = PartialDate(year: 1993, month: 2, day: 13)
    let jumpknuckleLast = PartialDate(year: 1994, month: 12, day: 28)
    XCTAssertEqual([jumpknuckleFirst, jumpknuckleLast].yearSpan, 2)

    let posterchildrenFirst = PartialDate(year: 1989, month: 1, day: 17)
    let posterchildrenLast = PartialDate(year: 2016, month: 10, day: 16)
    XCTAssertEqual([unknownDate, posterchildrenFirst, posterchildrenLast].yearSpan, 27)

    let humFirst = PartialDate(year: 1991, month: 11, day: 23)
    let humLast = PartialDate(year: 2015, month: 9, day: 18)
    XCTAssertEqual([humFirst, humLast].yearSpan, 23)

    let initialDate = PartialDate(year: 2023, month: 2, day: 6)
    let nextDay = PartialDate(year: 2023, month: 2, day: 7)
    let nextMonth = PartialDate(year: 2023, month: 3, day: 1)
    let nextMonthToTheDay = PartialDate(year: 2023, month: 3, day: 6)
    let almostNextYear = PartialDate(year: 2023, month: 12, day: 15)
    let yearJustChanged = PartialDate(year: 2024, month: 1, day: 1)
    let almostAYearLater = PartialDate(year: 2024, month: 2, day: 5)
    let oneYearToTheDayLater = PartialDate(year: 2024, month: 2, day: 6)
    let oneYearAndOneDayLater = PartialDate(year: 2024, month: 2, day: 7)
    let twoYearsToTheDayLater = PartialDate(year: 2025, month: 2, day: 6)
    let twoYearsAndOneDayLater = PartialDate(year: 2025, month: 2, day: 7)
    let threeYearsToTheDayLater = PartialDate(year: 2026, month: 2, day: 6)
    let threeYearsAndOneDayLater = PartialDate(year: 2026, month: 2, day: 7)

    XCTAssertEqual([initialDate, nextDay].yearSpan, 1)
    XCTAssertEqual([initialDate, nextMonth].yearSpan, 1)
    XCTAssertEqual([initialDate, nextMonthToTheDay].yearSpan, 1)
    XCTAssertEqual([initialDate, almostNextYear].yearSpan, 1)
    XCTAssertEqual([initialDate, yearJustChanged].yearSpan, 1)
    XCTAssertEqual([initialDate, almostAYearLater].yearSpan, 1)
    XCTAssertEqual([initialDate, oneYearToTheDayLater].yearSpan, 1)
    XCTAssertEqual([initialDate, oneYearAndOneDayLater].yearSpan, 2)
    XCTAssertEqual([initialDate, twoYearsToTheDayLater].yearSpan, 2)
    XCTAssertEqual([initialDate, twoYearsAndOneDayLater].yearSpan, 2)
    XCTAssertEqual([initialDate, threeYearsToTheDayLater].yearSpan, 3)
    XCTAssertEqual([initialDate, threeYearsAndOneDayLater].yearSpan, 3)
  }
}
