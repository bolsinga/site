//
//  DateMidnightTests.swift
//
//
//  Created by Greg Bolsinga on 5/16/23.
//

import XCTest

@testable import Site

final class DateMidnightTests: XCTestCase {
  func testMidnightInterval() throws {
    let nowDate = Date.now
    let nowHour = Calendar.autoupdatingCurrent.component(.hour, from: nowDate)
    let nextHourDate = Calendar.autoupdatingCurrent.date(
      bySetting: .hour, value: nowHour + 1, of: nowDate)!

    XCTAssertNotEqual(nowDate.timeIntervalSinceNow, nextHourDate.timeIntervalSinceNow)
    XCTAssertLessThan(nowDate.timeIntervalSinceNow, nextHourDate.timeIntervalSinceNow)

    XCTAssertEqual(nowDate.midnightTonight, nextHourDate.midnightTonight)
  }
}
