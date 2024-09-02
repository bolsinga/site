//
//  ArchiveNavigationTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import XCTest

@testable import Site

final class ArchiveNavigationTests: XCTestCase {
  func testNavigateToCategory() throws {
    let ar = ArchiveNavigation()
    XCTAssertNil(ar.selectedCategory)
    XCTAssertTrue(ar.navigationPath.isEmpty)

    ar.navigate(to: .today)
    XCTAssertEqual(ar.selectedCategory, .today)
    XCTAssertTrue(ar.navigationPath.isEmpty)

    ar.navigate(to: nil)
    XCTAssertNil(ar.selectedCategory)
    XCTAssertTrue(ar.navigationPath.isEmpty)
  }

  func testNavigateToArchivePath() throws {
    let ar = ArchiveNavigation()
    XCTAssertNil(ar.selectedCategory)
    XCTAssertTrue(ar.navigationPath.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    XCTAssertNil(ar.selectedCategory)
    XCTAssertEqual(ar.navigationPath.count, 1)

    XCTAssertNotNil(ar.navigationPath.first)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))
  }

  func testNavigateToArchivePath_noDoubles() throws {
    let ar = ArchiveNavigation()
    ar.navigate(to: ArchivePath.artist("id"))
    XCTAssertEqual(ar.navigationPath.count, 1)

    ar.navigate(to: ArchivePath.artist("id"))
    XCTAssertEqual(ar.navigationPath.count, 1)

    ar.navigate(to: ArchivePath.artist("id-1"))
    XCTAssertEqual(ar.navigationPath.count, 2)
  }
}
