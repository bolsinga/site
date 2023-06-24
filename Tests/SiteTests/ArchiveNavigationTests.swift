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

    ar.navigate(to: .today)
    XCTAssertEqual(ar.selectedCategory, .today)

    ar.navigate(to: nil)
    XCTAssertNil(ar.selectedCategory)
  }

  func testNavigateToArchivePath() throws {
    let ar = ArchiveNavigation()
    XCTAssertTrue(ar.navigationPath.isEmpty)

    ar.navigate(to: ArchivePath.artist("id"))
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

  func testRestoreNavigation_trueCategoryAndTruePath() throws {
    let ar = ArchiveNavigation()
    XCTAssertNil(ar.pendingNavigationPath)

    let pathData = [ArchivePath.artist("id")].jsonData
    ar.restoreNavigation(selectedCategoryStorage: .today, pathData: pathData)

    XCTAssertNotNil(ar.selectedCategory)
    XCTAssertEqual(ar.selectedCategory, .today)

    XCTAssertTrue(ar.navigationPath.isEmpty)
    XCTAssertNil(ar.navigationPath.first)

    XCTAssertNotNil(ar.pendingNavigationPath)
    XCTAssertEqual(ar.pendingNavigationPath?.count, 1)
    XCTAssertNotNil(ar.pendingNavigationPath?.first)
    XCTAssertEqual(ar.pendingNavigationPath?.first!, ArchivePath.artist("id"))
  }

  func testRestoreNavigation_nilCategoryAndTruePath() throws {
    let ar = ArchiveNavigation()
    XCTAssertNil(ar.pendingNavigationPath)

    let pathData = [ArchivePath.artist("id")].jsonData
    ar.restoreNavigation(selectedCategoryStorage: nil, pathData: pathData)

    XCTAssertNil(ar.selectedCategory)
    XCTAssertNotEqual(ar.selectedCategory, .today)

    XCTAssertFalse(ar.navigationPath.isEmpty)
    XCTAssertNotNil(ar.navigationPath.first)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))

    XCTAssertNil(ar.pendingNavigationPath)
  }

  func testRestoreNavigation_trueCategoryAndNilPath() throws {
    let ar = ArchiveNavigation()
    XCTAssertNil(ar.pendingNavigationPath)

    ar.restoreNavigation(selectedCategoryStorage: .today, pathData: nil)

    XCTAssertNotNil(ar.selectedCategory)
    XCTAssertEqual(ar.selectedCategory, .today)

    XCTAssertTrue(ar.navigationPath.isEmpty)
    XCTAssertNil(ar.navigationPath.first)

    XCTAssertNil(ar.pendingNavigationPath)
  }

  func testRestoreNavigation_nilCategoryAndNilPath() throws {
    let ar = ArchiveNavigation()
    XCTAssertNil(ar.pendingNavigationPath)

    ar.restoreNavigation(selectedCategoryStorage: nil, pathData: nil)

    XCTAssertNil(ar.selectedCategory)
    XCTAssertNotEqual(ar.selectedCategory, .today)

    XCTAssertTrue(ar.navigationPath.isEmpty)
    XCTAssertNil(ar.navigationPath.first)

    XCTAssertNil(ar.pendingNavigationPath)
  }

  func testRestorePendingData() throws {
    let ar = ArchiveNavigation()
    XCTAssertNil(ar.pendingNavigationPath)

    let pathData = [ArchivePath.artist("id")].jsonData
    ar.restoreNavigation(selectedCategoryStorage: .today, pathData: pathData)

    XCTAssertNotNil(ar.selectedCategory)
    XCTAssertEqual(ar.selectedCategory, .today)

    XCTAssertTrue(ar.navigationPath.isEmpty)
    XCTAssertNil(ar.navigationPath.first)

    XCTAssertNotNil(ar.pendingNavigationPath)
    XCTAssertEqual(ar.pendingNavigationPath?.count, 1)
    XCTAssertNotNil(ar.pendingNavigationPath?.first)
    XCTAssertEqual(ar.pendingNavigationPath?.first!, ArchivePath.artist("id"))

    ar.restorePendingData()
    XCTAssertNotNil(ar.selectedCategory)
    XCTAssertEqual(ar.selectedCategory, .today)

    XCTAssertFalse(ar.navigationPath.isEmpty)
    XCTAssertNotNil(ar.navigationPath.first)
    XCTAssertEqual(ar.navigationPath.first!, ArchivePath.artist("id"))

    XCTAssertNil(ar.pendingNavigationPath)
  }
}
