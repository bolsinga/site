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
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)
    XCTAssertTrue(ar.state.path.isEmpty)

    ar.navigate(to: .today)
    XCTAssertEqual(ar.state.category, .today)
    XCTAssertTrue(ar.state.path.isEmpty)

    ar.navigate(to: .stats)
    XCTAssertEqual(ar.state.category, .stats)
    XCTAssertTrue(ar.state.path.isEmpty)

    ar.navigate(to: .artists)
    XCTAssertEqual(ar.state.category, .artists)
    XCTAssertTrue(ar.state.path.isEmpty)

    ar.navigate(to: .venues)
    XCTAssertEqual(ar.state.category, .venues)
    XCTAssertTrue(ar.state.path.isEmpty)

    ar.navigate(to: .shows)
    XCTAssertEqual(ar.state.category, .shows)
    XCTAssertTrue(ar.state.path.isEmpty)

    #if os(iOS) || os(tvOS)
      ar.navigate(to: nil)
      XCTAssertNil(ar.state.category)
      XCTAssertTrue(ar.state.path.isEmpty)
    #endif
  }

  func testNavigateToCategory_existingPath() {
    let ar = ArchiveNavigation(
      ArchiveNavigation.State(
        category: .artists, path: [Artist(id: "id", name: "name").archivePath]))
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, .artists)
    XCTAssertFalse(ar.state.path.isEmpty)
    XCTAssertEqual(ar.state.path.first!, Artist(id: "id", name: "name").archivePath)

    ar.navigate(to: .venues)
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, .venues)
    XCTAssertTrue(ar.state.path.isEmpty)
  }

  func testNavigateToArchivePath() throws {
    let ar = ArchiveNavigation()
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)
    XCTAssertTrue(ar.state.path.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)
    XCTAssertEqual(ar.state.path.count, 1)
    XCTAssertNotNil(ar.state.path.last)
    XCTAssertEqual(ar.state.path.last!, ArchivePath.artist("id"))

    ar.navigate(to: ArchivePath.venue("id"))
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)
    XCTAssertEqual(ar.state.path.count, 2)
    XCTAssertNotNil(ar.state.path.last)
    XCTAssertEqual(ar.state.path.last!, ArchivePath.venue("id"))

    ar.navigate(to: ArchivePath.show("id"))
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)
    XCTAssertEqual(ar.state.path.count, 3)
    XCTAssertNotNil(ar.state.path.last)
    XCTAssertEqual(ar.state.path.last!, ArchivePath.show("id"))

    ar.navigate(to: ArchivePath.year(Annum.year(1989)))
    #if os(iOS) || os(tvOS)
      XCTAssertNotNil(ar.state.category)
    #endif
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)
    XCTAssertEqual(ar.state.path.count, 4)
    XCTAssertNotNil(ar.state.path.last)
    XCTAssertEqual(ar.state.path.last!, ArchivePath.year(Annum.year(1989)))
  }

  func testNavigateToArchivePath_noDoubles() throws {
    let ar = ArchiveNavigation()
    ar.navigate(to: ArchivePath.artist("id"))
    XCTAssertEqual(ar.state.path.count, 1)
    XCTAssertEqual(ar.state.path.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.artist("id"))
    XCTAssertEqual(ar.state.path.count, 1)
    XCTAssertEqual(ar.state.path.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.artist("id-1"))
    XCTAssertEqual(ar.state.path.count, 2)
    XCTAssertEqual(ar.state.path.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.state.path.last!, ArchivePath.artist("id-1"))
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)

    ar.navigate(to: ArchivePath.venue("vid-1"))
    XCTAssertEqual(ar.state.path.count, 3)
    XCTAssertEqual(ar.state.path.first!, ArchivePath.artist("id"))
    XCTAssertEqual(ar.state.path.last!, ArchivePath.venue("vid-1"))
    XCTAssertEqual(ar.state.category, ArchiveNavigation.State.defaultCategory)
  }
}
