//
//  ArchivePathTests.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import XCTest

@testable import Site

final class ArchivePathTests: XCTestCase {
  func testFormat() throws {
    XCTAssertEqual(ArchivePath.show("someIdentifier").formatted(), "sh-someIdentifier")
    XCTAssertEqual(ArchivePath.venue("someIdentifier").formatted(), "v-someIdentifier")
    XCTAssertEqual(ArchivePath.artist("someIdentifier").formatted(), "ar-someIdentifier")
    XCTAssertEqual(ArchivePath.year(Annum.year(1989)).formatted(), "y-1989")
    XCTAssertEqual(ArchivePath.year(Annum.unknown).formatted(), "y-unknown")
  }

  func testParse() throws {
    XCTAssertEqual(try ArchivePath("y-1989"), ArchivePath.year(Annum.year(1989)))
    XCTAssertEqual(try ArchivePath("y-unknown"), ArchivePath.year(Annum.unknown))
    XCTAssertThrowsError(try ArchivePath("y-ZZZ"))

    XCTAssertEqual(try ArchivePath(" y-1989"), ArchivePath.year(Annum.year(1989)))
    XCTAssertEqual(try ArchivePath("y-1989 "), ArchivePath.year(Annum.year(1989)))

    XCTAssertEqual(try ArchivePath("sh-someIdentifier"), ArchivePath.show("someIdentifier"))
    XCTAssertEqual(try ArchivePath("v-someIdentifier"), ArchivePath.venue("someIdentifier"))
    XCTAssertEqual(try ArchivePath("ar-someIdentifier"), ArchivePath.artist("someIdentifier"))

    XCTAssertThrowsError(try ArchivePath("a-someIdentifier"))
    XCTAssertThrowsError(try ArchivePath("av-someIdentifier"))

    XCTAssertEqual(
      try ArchivePath("ar-id-WithSeparatorWithinIt"), ArchivePath.artist("id-WithSeparatorWithinIt")
    )

    let newlineBefore = """

          y-1989
      """
    let newlineAfter = """
          y-1989

      """
    let newlineMiddle = """
          y-19
      89
      """
    XCTAssertThrowsError(try ArchivePath(newlineBefore))
    XCTAssertThrowsError(try ArchivePath(newlineAfter))
    XCTAssertThrowsError(try ArchivePath(newlineMiddle))

    XCTAssertThrowsError(try ArchivePath("z1989"))
    XCTAssertThrowsError(try ArchivePath("1989z"))

    XCTAssertThrowsError(try ArchivePath("zzz"))

    XCTAssertThrowsError(try ArchivePath(""))
    XCTAssertThrowsError(try ArchivePath(" "))
  }
}