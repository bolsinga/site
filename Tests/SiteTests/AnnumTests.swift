//
//  AnnumTests.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import XCTest

@testable import Site

final class AnnumTests: XCTestCase {
  func testFormat() throws {
    XCTAssertEqual(Annum.year(1989).formatted(), "1989")
    XCTAssertEqual(Annum.unknown.formatted(), "Year Unknown")
  }

  func testParse() throws {
    XCTAssertEqual(try Annum("1989"), Annum.year(1989))

    XCTAssertEqual(try Annum(" 1989"), Annum.year(1989))
    XCTAssertEqual(try Annum("1989 "), Annum.year(1989))

    let newlineBefore = """

          1989
      """
    let newlineAfter = """
          1989

      """
    let newlineMiddle = """
          19
      89
      """
    XCTAssertThrowsError(try Annum(newlineBefore))
    XCTAssertThrowsError(try Annum(newlineAfter))
    XCTAssertThrowsError(try Annum(newlineMiddle))

    XCTAssertThrowsError(try Annum("z1989"))
    XCTAssertThrowsError(try Annum("1989z"))

    XCTAssertThrowsError(try Annum("zzz"))
    XCTAssertEqual(try Annum("Year Unknown"), Annum.unknown)
  }
}
