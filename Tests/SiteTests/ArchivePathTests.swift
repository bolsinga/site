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

  func testPathAndFragmentFormat() throws {
    XCTAssertEqual(
      ArchivePath.show("someIdentifier").formatted(.urlPath), "/dates/someIdentifier.html")
    XCTAssertEqual(
      ArchivePath.venue("someIdentifier").formatted(.urlPath), "/venues/someIdentifier.html")
    XCTAssertEqual(
      ArchivePath.artist("someIdentifier").formatted(.urlPath), "/bands/someIdentifier.html")
    XCTAssertEqual(ArchivePath.year(Annum.year(1989)).formatted(.urlPath), "/dates/1989.html")
    XCTAssertEqual(ArchivePath.year(Annum.unknown).formatted(.urlPath), "/dates/other.html")
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

  func testURLFormat() throws {
    XCTAssertEqual(
      try ArchivePath(URL(string: "https://www.example.com/bands/ar852.html")!),
      ArchivePath.artist("ar852"))
    XCTAssertEqual(
      try ArchivePath(URL(string: "https://www.example.com/venues/ar852.html")!),
      ArchivePath.venue("ar852"))
    XCTAssertEqual(
      try ArchivePath(URL(string: "https://www.example.com/dates/ar852.html")!),
      ArchivePath.show("ar852"))
    XCTAssertThrowsError(
      try ArchivePath(URL(string: "https://www.example.com/venues/L.html#ar852")!))
    XCTAssertThrowsError(try ArchivePath(URL(string: "https://www.example.com/venues/ar852")!))
    XCTAssertThrowsError(
      try ArchivePath(URL(string: "https://www.example.com/archives/ar852.html")!))
    XCTAssertThrowsError(try ArchivePath(URL(string: "https://www.example.com/bands/")!))
    XCTAssertThrowsError(try ArchivePath(URL(string: "https://www.example.com/")!))
    XCTAssertThrowsError(try ArchivePath(URL(string: "http://www.example.com/")!))
  }

  func testArchiveCategories() throws {
    XCTAssertEqual(try ArchivePath.artist("blah").category(), ArchiveCategory.artists)
    XCTAssertEqual(try ArchivePath.venue("blah").category(), ArchiveCategory.venues)
    XCTAssertEqual(try ArchivePath.show("blah").category(), ArchiveCategory.shows)
    XCTAssertThrowsError(try ArchivePath.year(.year(1989)).category())
    XCTAssertThrowsError(try ArchivePath.year(.unknown).category())
  }
}
