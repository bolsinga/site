//
//  PathRestorableUserActivityTests.swift
//
//
//  Created by Greg Bolsinga on 6/24/23.
//

import XCTest

@testable import Site

final class PathRestorableUserActivityTests: XCTestCase {
  let baseURL = Vault.previewData.baseURL

  func testShow() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let concert = Concert(
      show: Show(artists: [], date: PartialDate(), id: "sh17", venue: "v0"),
      venue: Venue(id: "v0", location: Location(city: "c", state: "s"), name: "V0"), artists: [],
      url: URL(string: "https://hey")!)
    userActivity.update(concert, url: concert.url)

    XCTAssertTrue(userActivity.isEligibleForHandoff)

    XCTAssertEqual(userActivity.targetContentIdentifier, "sh-sh17")

    XCTAssertTrue(userActivity.isEligibleForSearch)
    XCTAssertNotNil(userActivity.contentAttributeSet)

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertNotNil(userActivity.webpageURL)

    XCTAssertEqual(try userActivity.archivePath(), try ArchivePath("sh-sh17"))

    XCTAssertNotNil(userActivity.expirationDate)
  }

  func testArtist() throws {
    let userActivity = NSUserActivity(activityType: "test-type")

    let artist = Artist(id: "ar0", name: "AR0")
    userActivity.update(artist, url: artist.archivePath.url(using: baseURL))

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

    let venue = Venue(id: "v10", location: Location(city: "c", state: "s"), name: "V10")
    userActivity.update(venue, url: venue.archivePath.url(using: baseURL))

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

    userActivity.update(item, url: item.archivePath.url(using: baseURL))

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

    let concert = Concert(
      show: Show(artists: [], date: PartialDate(), id: "sh17", venue: "v0"),
      venue: Venue(id: "v0", location: Location(city: "c", state: "s"), name: "V0"), artists: [],
      url: URL(string: "https://hey")!)

    userActivity.update(concert, url: concert.url)

    XCTAssertTrue(userActivity.isEligibleForPublicIndexing)
    XCTAssertNotNil(userActivity.webpageURL)
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
