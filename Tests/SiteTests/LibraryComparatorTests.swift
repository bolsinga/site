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
    XCTAssertFalse(libraryCompare(lhs: "White Denim", rhs: "The White Album"))
  }

  func testStringAPrefix() throws {
    // These should compare as false, since removing the prefix matches the other word.
    XCTAssertFalse(libraryCompare(lhs: "A Cord", rhs: "Cord"))
    XCTAssertFalse(libraryCompare(lhs: "Cord", rhs: "A Cord"))
  }

  func testStringAnPrefix() throws {
    // These should compare as false, since removing the prefix matches the other word.
    XCTAssertFalse(libraryCompare(lhs: "An Other", rhs: "Other"))
    XCTAssertFalse(libraryCompare(lhs: "Other", rhs: "An Other"))
  }

  func testPrefixThreeWords() throws {
    // These should compare as false, since removing the prefix matches the other words.
    XCTAssertFalse(libraryCompare(lhs: "An Other Test", rhs: "Other Test"))
    XCTAssertFalse(libraryCompare(lhs: "Other Test", rhs: "An Other Test"))
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
    XCTExpectFailure("Multiple Words Do Not Work Correctly.") {
      XCTAssertEqual(chomp("A Cord Down"), "Cord Down")
    }
    XCTAssertEqual(chomp("A Cord"), "Cord")
  }

  func testAnPrefixChomp() throws {
    XCTExpectFailure("Multiple Words Do Not Work Correctly.") {
      XCTAssertEqual(chomp("An Other Word"), "Other Word")
    }
    XCTAssertEqual(chomp("An Other"), "Other")
  }

  func testThePrefixChomp() throws {
    XCTExpectFailure("Multiple Words Do Not Work Correctly.") {
      XCTAssertEqual(chomp("The White Album"), "White Album")
    }
    XCTAssertEqual(chomp("The White"), "White")
  }

  func testPrefixLowercaseTwoWords() throws {
    XCTAssertEqual(chomp("the White"), "White")
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

  func testQuotedChomp() throws {
    XCTExpectFailure("This just chomps to the first word") {
      XCTAssertEqual(chomp("\"Song Title\""), "Song Title")
    }
    XCTExpectFailure("This just chomps to the first word") {
      XCTAssertEqual(chomp("\"Longer Song Title\""), "Longer Song Title")
    }
  }
}
