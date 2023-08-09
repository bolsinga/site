//
//  ArchiveCategoryTests.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import XCTest

@testable import Site

final class ArchiveCategoryTests: XCTestCase {
  func testFormat() throws {
    XCTAssertEqual(ArchiveCategory.today.formatted(.urlPath), "/dates/today.html")
    XCTAssertEqual(ArchiveCategory.stats.formatted(.urlPath), "/stats.html")
    XCTAssertEqual(ArchiveCategory.shows.formatted(.urlPath), "/dates/stats.html")
    XCTAssertEqual(ArchiveCategory.venues.formatted(.urlPath), "/venues/stats.html")
    XCTAssertEqual(ArchiveCategory.artists.formatted(.urlPath), "/bands/stats.html")
  }

  func testParseURLFormat() throws {
    XCTAssertEqual(
      try ArchiveCategory(URL(string: "https://www.example.com/dates/today.html")!),
      ArchiveCategory.today)
    XCTAssertEqual(
      try ArchiveCategory(URL(string: "https://www.example.com/stats.html")!), ArchiveCategory.stats
    )
    XCTAssertEqual(
      try ArchiveCategory(URL(string: "https://www.example.com/dates/stats.html")!),
      ArchiveCategory.shows)
    XCTAssertEqual(
      try ArchiveCategory(URL(string: "https://www.example.com/venues/stats.html")!),
      ArchiveCategory.venues)
    XCTAssertEqual(
      try ArchiveCategory(URL(string: "https://www.example.com/bands/stats.html")!),
      ArchiveCategory.artists)

    XCTAssertThrowsError(try ArchiveCategory(URL(string: "https://www.example.com/today.html")!))
    XCTAssertThrowsError(
      try ArchiveCategory(URL(string: "https://www.example.com/today.html#blah")!))
    XCTAssertThrowsError(try ArchiveCategory(URL(string: "https://www.example.com/today")!))
    XCTAssertThrowsError(try ArchiveCategory(URL(string: "https://www.example.com/bands/")!))
    XCTAssertThrowsError(try ArchiveCategory(URL(string: "https://www.example.com/")!))
    XCTAssertThrowsError(try ArchiveCategory(URL(string: "http://www.example.com/")!))
  }
}
