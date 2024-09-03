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
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.selectedCategory)
    #endif
    XCTAssertEqual(ar.selectedCategory, ArchiveNavigation.State.defaultCategory)
    XCTAssertTrue(ar.navigationPath.isEmpty)

    ar.navigate(to: .today)
    XCTAssertEqual(ar.selectedCategory, .today)
    XCTAssertTrue(ar.navigationPath.isEmpty)

    #if os(iOS) || os(tvOS)
      ar.navigate(to: nil)
      XCTAssertNil(ar.selectedCategory)
      XCTAssertTrue(ar.navigationPath.isEmpty)
    #endif
  }

  func testNavigateToCategory_existingPath() {
    let ar = ArchiveNavigation(
      ArchiveNavigation.State(
        category: .artists, path: [Artist(id: "id", name: "name").archivePath]))
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.selectedCategory)
    #endif
    XCTAssertEqual(ar.selectedCategory, .artists)
    XCTAssertFalse(ar.navigationPath.isEmpty)
    XCTAssertEqual(ar.navigationPath.first!, Artist(id: "id", name: "name").archivePath)

    ar.navigate(to: .venues)
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.selectedCategory)
    #endif
    XCTAssertEqual(ar.selectedCategory, .venues)
    XCTAssertTrue(ar.navigationPath.isEmpty)
  }

  func testNavigateToArchivePath() throws {
    let ar = ArchiveNavigation()
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.selectedCategory)
    #endif
    XCTAssertEqual(ar.selectedCategory, ArchiveNavigation.State.defaultCategory)
    XCTAssertTrue(ar.navigationPath.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.selectedCategory)
    #endif
    XCTAssertEqual(ar.selectedCategory, ArchiveNavigation.State.defaultCategory)
    XCTAssertEqual(ar.navigationPath.count, 1)

    XCTAssertNotNil(ar.navigationPath.first)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))
  }

  func testNavigateToArchivePath_noDoubles() throws {
    let ar = ArchiveNavigation()
    ar.navigate(to: ArchivePath.artist("id"))
    XCTAssertEqual(ar.navigationPath.count, 1)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.selectedCategory, ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.artist("id"))
    XCTAssertEqual(ar.navigationPath.count, 1)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.selectedCategory, ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.artist("id-1"))
    XCTAssertEqual(ar.navigationPath.count, 2)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.navigationPath.last!, ArchivePath.artist("id-1"))
    XCTAssertEqual(ar.selectedCategory, ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.venue("vid-1"))
    XCTAssertEqual(ar.navigationPath.count, 3)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.navigationPath.last!, ArchivePath.venue("vid-1"))
    XCTAssertEqual(ar.selectedCategory, ArchiveNavigation.State.defaultCategory)
  }
}
