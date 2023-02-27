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
}
