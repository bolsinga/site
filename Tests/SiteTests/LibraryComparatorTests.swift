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

  func testAPrefixChomp() throws {
    XCTExpectFailure("Prefix does not work currently.") {
      XCTAssertEqual(chomp("A Cord Down"), "Cord Down")
    }
  }

  func testAnPrefixChomp() throws {
    XCTExpectFailure("Prefix does not work currently.") {
      XCTAssertEqual(chomp("An Other Word"), "Other Word")
    }
  }

  func testThePrefixChomp() throws {
    XCTExpectFailure("Prefix does not work currently.") {
      XCTAssertEqual(chomp("The White Album"), "White Album")
    }
  }

  func testPrefixTwoWords() throws {
    XCTAssertEqual(chomp("The White"), "White")
  }

  func testPrefixLowercaseTwoWords() throws {
    XCTExpectFailure("Lower case tests do not work.") {
      XCTAssertEqual(chomp("the White"), "White")
    }
  }

  func testSmogChomp() throws {
    XCTAssertEqual(chomp("(Smog)"), "Smog")
  }

  func testMultipleSmogChomp() throws {
    XCTExpectFailure("Multiple words in parenthesis does not work currently.") {
      XCTAssertEqual(chomp("(Smog Haze)"), "Smog Haze")
    }
  }

  func testTrailOfDeadChomp() throws {
    XCTExpectFailure("This just does not work currently.") {
      XCTAssertEqual(
        chomp("...And You Will Know Us By The Trail Of Dead"),
        "And You Will Know Us By The Trail Of Dead")
    }
  }

  func testHardDaysChomp() throws {
    XCTExpectFailure("This just does not work currently.") {
      XCTAssertEqual(chomp("A Hard Day's Night"), "Hard Day's Night")
    }
  }

  func testOldEnoughChomp() throws {
    XCTExpectFailure("This just does not work currently.") {
      XCTAssertEqual(
        chomp("Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)"),
        "Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)")
    }
  }
}
