//
//  LibraryComparatorTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import XCTest

@testable import Site

final class LibraryComparatorTests: XCTestCase {
  func testStringBasic() throws {
    XCTAssertTrue(libraryCompare(lhs: "A", rhs: "B"))
    XCTAssertFalse(libraryCompare(lhs: "B", rhs: "A"))
  }

  func testStringThePrefix() throws {
    XCTExpectFailure("Prefix does not work currently.") {
      XCTAssertTrue(libraryCompare(lhs: "The White Album", rhs: "White Denim"))
    }
    XCTAssertFalse(libraryCompare(lhs: "The White Album", rhs: "White Denim"))
  }

  func testStringAPrefix() throws {
    XCTExpectFailure("Prefix does not work currently.") {
      XCTAssertTrue(libraryCompare(lhs: "A Cord", rhs: "Cord"))
    }
    XCTAssertFalse(libraryCompare(lhs: "Cord", rhs: "A Cord"))
  }

  func testStringAnPrefix() throws {
    XCTExpectFailure("Prefix does not work currently.") {
      XCTAssertTrue(libraryCompare(lhs: "An Other", rhs: "Other"))
    }
    XCTAssertFalse(libraryCompare(lhs: "Other", rhs: "An Other"))
  }

  func testStringPartialPrefix() throws {
    XCTAssertTrue(libraryCompare(lhs: "These", rhs: "They Might"))
    XCTAssertFalse(libraryCompare(lhs: "They Might", rhs: "These"))

    XCTAssertTrue(libraryCompare(lhs: "Them", rhs: "They Might"))
    XCTAssertFalse(libraryCompare(lhs: "They Might", rhs: "Them"))
  }

  func testStringSmog() throws {
    XCTAssertFalse(libraryCompare(lhs: "Smog", rhs: "(Smog)"))
    XCTAssertFalse(libraryCompare(lhs: "(Smog)", rhs: "Smog"))
  }

  func testStringQuotation() throws {
    // This is actually funky since this becomes a comparison of the string "Song" not "Song Title".
    XCTAssertFalse(libraryCompare(lhs: "\"Song Title\"", rhs: "Song Title"))
    XCTAssertFalse(libraryCompare(lhs: "Song Title", rhs: "\"Song Title\""))
  }
}
