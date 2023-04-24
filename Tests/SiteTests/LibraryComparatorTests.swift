//
//  LibraryComparatorTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import XCTest

@testable import Site

final class LibraryComparatorTests: XCTestCase {
  let comparator = LibraryComparator()

  func testStringBasic() throws {
    XCTAssertTrue(comparator.libraryCompare(lhs: "A", rhs: "B"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "B", rhs: "A"))
  }

  func testStringThePrefix() throws {
    XCTAssertTrue(comparator.libraryCompare(lhs: "The White Album", rhs: "White Denim"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "White Denim", rhs: "The White Album"))
  }

  func testStringAPrefix() throws {
    // These should compare as false, since removing the prefix matches the other word.
    XCTAssertFalse(comparator.libraryCompare(lhs: "A Cord", rhs: "Cord"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "Cord", rhs: "A Cord"))
  }

  func testStringAnPrefix() throws {
    // These should compare as false, since removing the prefix matches the other word.
    XCTAssertFalse(comparator.libraryCompare(lhs: "An Other", rhs: "Other"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "Other", rhs: "An Other"))
  }

  func testPrefixThreeWords() throws {
    // These should compare as false, since removing the prefix matches the other words.
    XCTAssertFalse(comparator.libraryCompare(lhs: "An Other Test", rhs: "Other Test"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "Other Test", rhs: "An Other Test"))
  }

  func testStringPartialPrefix() throws {
    XCTAssertTrue(comparator.libraryCompare(lhs: "These", rhs: "They Might"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "They Might", rhs: "These"))

    XCTAssertTrue(comparator.libraryCompare(lhs: "Them", rhs: "They Might"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "They Might", rhs: "Them"))
  }

  func testStringSmog() throws {
    XCTAssertFalse(comparator.libraryCompare(lhs: "Smog", rhs: "(Smog)"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "(Smog)", rhs: "Smog"))
  }

  func testStringQuotation() throws {
    XCTAssertFalse(comparator.libraryCompare(lhs: "\"Song Title\"", rhs: "Song Title"))
    XCTAssertFalse(comparator.libraryCompare(lhs: "Song Title", rhs: "\"Song Title\""))
  }

  func testAPrefixChomp() throws {
    XCTAssertEqual("A Cord Down".removeCommonInitialPunctuation, "Cord Down")
    XCTAssertEqual("A Cord".removeCommonInitialPunctuation, "Cord")
  }

  func testAnPrefixChomp() throws {
    XCTAssertEqual("An Other Word".removeCommonInitialPunctuation, "Other Word")
    XCTAssertEqual("An Other".removeCommonInitialPunctuation, "Other")
  }

  func testThePrefixChomp() throws {
    XCTAssertEqual("The White Album".removeCommonInitialPunctuation, "White Album")
    XCTAssertEqual("The White".removeCommonInitialPunctuation, "White")
  }

  func testPrefixLowercaseTwoWords() throws {
    XCTAssertEqual("the White".removeCommonInitialPunctuation, "White")
  }

  func testSmogChomp() throws {
    XCTAssertEqual("(Smog)".removeCommonInitialPunctuation, "Smog")
  }

  func testMultipleSmogChomp() throws {
    XCTAssertEqual("(Smog Haze)".removeCommonInitialPunctuation, "Smog Haze")
  }

  func testTrailOfDeadChomp() throws {
    XCTAssertEqual(
      "...And You Will Know Us By The Trail Of Dead".removeCommonInitialPunctuation,
      "And You Will Know Us By The Trail Of Dead")
  }

  func testHardDaysChomp() throws {
    XCTAssertEqual("A Hard Day's Night".removeCommonInitialPunctuation, "Hard Day's Night")
  }

  func testOldEnoughChomp() throws {
    XCTAssertEqual(
      "Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)"
        .removeCommonInitialPunctuation,
      "Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)")
  }

  func testQuotedChomp() throws {
    XCTAssertEqual("\"Song Title\"".removeCommonInitialPunctuation, "Song Title")
    XCTAssertEqual("\"Longer Song Title\"".removeCommonInitialPunctuation, "Longer Song Title")
  }
}
