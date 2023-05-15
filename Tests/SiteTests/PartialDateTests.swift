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

    XCTAssertEqual([date1, date2].yearSpan(), 3)
    XCTAssertEqual([date1, date1].yearSpan(), 1)
    XCTAssertEqual([date2, date2].yearSpan(), 1)
    XCTAssertEqual([unknownDate].yearSpan(), 1)
    XCTAssertEqual([unknownDate, unknownDate].yearSpan(), 1)
    XCTAssertEqual([unknownDate, date1].yearSpan(), 1)
    XCTAssertEqual([unknownDate, date1, date2].yearSpan(), 3)

    XCTAssertEqual([PartialDate]().yearSpan(), 0)
  }
}
