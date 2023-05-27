//
//  DecadeTests.swift
//
//
//  Created by Greg Bolsinga on 5/26/23.
//

import XCTest

@testable import Site

final class DecadeTests: XCTestCase {

  func testInt() throws {
    XCTAssertEqual(1910.decade, .decade(1910))
    XCTAssertEqual(1911.decade, .decade(1910))
    XCTAssertEqual(1919.decade, .decade(1910))
    XCTAssertEqual(1920.decade, .decade(1920))
    XCTAssertEqual(1921.decade, .decade(1920))
  }

  func testPartialDate() throws {
    XCTAssertEqual(PartialDate().decade, .unknown)
    XCTAssertEqual(PartialDate(year: 1910).decade, .decade(1910))
    XCTAssertEqual(PartialDate(year: 1920).decade, .decade(1920))
    XCTAssertEqual(PartialDate(month: 10).decade, .unknown)
    XCTAssertEqual(PartialDate(month: 10, day: 15).decade, .unknown)
    XCTAssertEqual(PartialDate(day: 15).decade, .unknown)
  }

  func testFormats() throws {
    XCTAssertEqual(1910.decade.formatted(.defaultDigits), "1910s")
    XCTAssertEqual(1911.decade.formatted(.defaultDigits), "1910s")
    XCTAssertEqual(1910.decade.formatted(.twoDigits), "10’s")
    XCTAssertEqual(1911.decade.formatted(.twoDigits), "10’s")

    XCTAssertEqual(1990.decade.formatted(.twoDigits), "90’s")
    XCTAssertEqual(2000.decade.formatted(.twoDigits), "00’s")
    XCTAssertEqual(2010.decade.formatted(.twoDigits), "10’s")

    XCTAssertEqual(PartialDate().decade.formatted(.defaultDigits), "Decade Unknown")
    XCTAssertEqual(PartialDate().decade.formatted(.twoDigits), "Decade Unknown")
  }
}
