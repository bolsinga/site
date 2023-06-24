//
//  PathRestorableUserActivityTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import XCTest

@testable import Site

final class PathRestorableUserActivityTests: XCTestCase {
  func testShow() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let item = Show(artists: [], date: PartialDate(), id: "1", venue: "1")

    XCTAssertNoThrow(try userActivity.update(item, url: nil))

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "sh-1")

    XCTAssertFalse(userActivity.isEligibleForSearch)
    XCTAssertNil(userActivity.contentAttributeSet)

    XCTAssertFalse(userActivity.isEligibleForPublicIndexing)
    XCTAssertNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("sh-1"))
  }

  func testArtist() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let item = Artist(id: "1", name: "name")

    XCTAssertNoThrow(try userActivity.update(item, url: nil))

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "ar-1")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertFalse(userActivity.isEligibleForPublicIndexing)
    XCTAssertNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("ar-1"))
  }

  func testVenue() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let item = Venue(id: "1", location: Location(city: "city", state: "st"), name: "name")

    XCTAssertNoThrow(try userActivity.update(item, url: nil))

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "v-1")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertFalse(userActivity.isEligibleForPublicIndexing)
    XCTAssertNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("v-1"))
  }

  func testAnnum() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let item = Annum.year(1990)

    XCTAssertNoThrow(try userActivity.update(item, url: nil))

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "y-1990")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertFalse(userActivity.isEligibleForPublicIndexing)
    XCTAssertNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("y-1990"))
  }

  func testShow_withURL() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let item = Show(artists: [], date: PartialDate(), id: "1", venue: "1")
    let url = URL(string: "https://www.example.com")!

    XCTAssertNoThrow(try userActivity.update(item, url: url))

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertEqual(userActivity.webpageURL, url)
  }
}
