//
//  LibrarySectionTests.swift
//
//
//  Created by Greg Bolsinga on 4/7/23.
//

import XCTest

@testable import Site

final class LibrarySectionTests: XCTestCase {
  func testLibrarySection() throws {
    XCTAssertEqual(librarySection("The Chapel"), .alphabetic("C"))

    XCTAssertEqual(librarySection("33 Degrees"), .numeric)

    XCTAssertEqual(librarySection("!!!"), .punctuation)
  }

  func testComparable() throws {
    XCTAssertTrue(LibrarySection.alphabetic("A") < .alphabetic("Z"))
    XCTAssertFalse(LibrarySection.alphabetic("A") > .alphabetic("Z"))

    XCTAssertTrue(LibrarySection.alphabetic("A") < .numeric)
    XCTAssertFalse(LibrarySection.alphabetic("A") > .numeric)

    XCTAssertTrue(LibrarySection.alphabetic("A") < .punctuation)
    XCTAssertFalse(LibrarySection.alphabetic("A") > .punctuation)

    XCTAssertTrue(LibrarySection.numeric < .punctuation)
    XCTAssertFalse(LibrarySection.numeric > .punctuation)
  }

  func testFormat() throws {
    XCTAssertEqual(LibrarySection.alphabetic("A").formatted(), "A")
    XCTAssertEqual(LibrarySection.numeric.formatted(), "Numeric")
    XCTAssertEqual(LibrarySection.punctuation.formatted(), "Punctuation")

    XCTAssertEqual(LibrarySection.alphabetic("A").formatted(.long), "A")
    XCTAssertEqual(LibrarySection.numeric.formatted(.long), "Numeric")
    XCTAssertEqual(LibrarySection.punctuation.formatted(.long), "Punctuation")

    XCTAssertEqual(LibrarySection.alphabetic("A").formatted(.short), "A")
    XCTAssertEqual(LibrarySection.numeric.formatted(.short), "#")
    XCTAssertEqual(LibrarySection.punctuation.formatted(.short), "!")
  }
}
