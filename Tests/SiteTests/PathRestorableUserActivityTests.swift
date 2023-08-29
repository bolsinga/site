//
//  PathRestorableUserActivityTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import XCTest

@testable import Site

final class PathRestorableUserActivityTests: XCTestCase {
  let vault = Vault.previewData

  func testShow() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    userActivity.update(vault.lookup.concert(from: vault.shows[0]), vault: vault)

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "sh-sh15")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertNotNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("sh-sh15"))

    XCTAssertNotNil(userActivity.expirationDate)
  }

  func testArtist() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    userActivity.update(vault.artists[0], vault: vault)

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "ar-ar0")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertNotNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("ar-ar0"))
  }

  func testVenue() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    userActivity.update(vault.venues[0], vault: vault)

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "v-v10")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertNotNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("v-v10"))
  }

  func testAnnum() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let item = Annum.year(1990)

    userActivity.update(item, vault: vault)

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "y-1990")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertNotNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("y-1990"))
  }

  func testShow_withURL() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let url = URL(string: "https://www.example.com/dates/sh15.html")!

    userActivity.update(vault.lookup.concert(from: vault.shows[0]), vault: vault)

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertEqual(userActivity.webpageURL, url)
  }

  func test_decodeError_noUserInfo() throws {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = nil

    XCTAssertThrowsError(try userActivity.archivePath())
  }

  func test_decodeError_emptyUserInfo() throws {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = [:]

    XCTAssertThrowsError(try userActivity.archivePath())
  }

  func test_decodeError_wrongType() throws {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = [NSUserActivity.archivePathKey: 6]

    XCTAssertThrowsError(try userActivity.archivePath())
  }

  func test_decode() throws {
    let userActivity = NSUserActivity(activityType: "test-type")
    userActivity.userInfo = [NSUserActivity.archivePathKey: "y-1988"]

    XCTAssertEqual(try userActivity.archivePath(), ArchivePath.year(Annum.year(1988)))
  }
}
