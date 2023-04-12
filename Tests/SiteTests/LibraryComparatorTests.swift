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
    XCTAssertTrue(libraryCompare(lhs: "The White Album", rhs: "White Denim"))
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
    XCTAssertFalse(libraryCompare(lhs: "\"Song Title\"", rhs: "Song Title"))
    XCTAssertFalse(libraryCompare(lhs: "Song Title", rhs: "\"Song Title\""))
  }

  func testAPrefixChomp() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("A Cord Down"), "Cord Down")
    XCTAssertEqual(removeCommonInitialPunctuation("A Cord"), "Cord")
  }

  func testAnPrefixChomp() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("An Other Word"), "Other Word")
    XCTAssertEqual(removeCommonInitialPunctuation("An Other"), "Other")
  }

  func testThePrefixChomp() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("The White Album"), "White Album")
    XCTAssertEqual(removeCommonInitialPunctuation("The White"), "White")
  }

  func testPrefixLowercaseTwoWords() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("the White"), "White")
  }

  func testSmogChomp() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("(Smog)"), "Smog")
  }

  func testMultipleSmogChomp() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("(Smog Haze)"), "Smog Haze")
  }

  func testTrailOfDeadChomp() throws {
    XCTAssertEqual(
      removeCommonInitialPunctuation("...And You Will Know Us By The Trail Of Dead"),
      "And You Will Know Us By The Trail Of Dead")
  }

  func testHardDaysChomp() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("A Hard Day's Night"), "Hard Day's Night")
  }

  func testOldEnoughChomp() throws {
    XCTAssertEqual(
      removeCommonInitialPunctuation(
        "Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)"),
      "Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)")
  }

  func testQuotedChomp() throws {
    XCTAssertEqual(removeCommonInitialPunctuation("\"Song Title\""), "Song Title")
    XCTAssertEqual(removeCommonInitialPunctuation("\"Longer Song Title\""), "Longer Song Title")
  }
}
