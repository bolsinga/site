//
//  EmphasizedMatchingTests.swift
//
//
//  Created by Greg Bolsinga on 6/15/24.
//

import XCTest

@testable import Site

final class EmphasizedMatchingTests: XCTestCase {
  func testJustOneLetterMatchingWithOneMatch() throws {
    XCTAssertEqual("Gre".emphasized(matching: "G"), "**G**re")
    XCTAssertEqual("Gre".emphasized(matching: "g"), "**G**re")
  }

  func testJustOneLetterMatchinWithMultipleMatches() throws {
    XCTAssertEqual("Greg".emphasized(matching: "G"), "**G**reg")
    XCTAssertEqual("Greg".emphasized(matching: "g"), "**G**reg")
  }

  func testTwoLettersMatchingWithOneMatch() throws {
    XCTAssertEqual("Greg".emphasized(matching: "Gr"), "**Gr**eg")
    XCTAssertEqual("Greg".emphasized(matching: "gr"), "**Gr**eg")
  }

  func testTwoLettersMatchingWithMultipleMatches() throws {
    XCTAssertEqual("Gregr".emphasized(matching: "Gr"), "**Gr**egr")
    XCTAssertEqual("GregR".emphasized(matching: "gr"), "**Gr**egR")
  }
}
