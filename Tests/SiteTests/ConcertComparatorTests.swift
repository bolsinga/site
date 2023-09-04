//
//  ConcertComparatorTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import XCTest

@testable import Site

final class ConcertComparatorTests: XCTestCase {
  let date = PartialDate(year: 1996, month: 12, day: 15)

  let venue1 = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "A Venue")
  let venue2 = Venue(id: "v1", location: Location(city: "city", state: "CA"), name: "B Venue")

  let artist1 = Artist(id: "ar0", name: "A Artist")
  let artist2 = Artist(id: "ar1", name: "B Artist")

  func createVault(artists: [Artist], shows: [Show], venues: [Venue]) -> Vault {
    Vault(
      music: Music(
        albums: [], artists: artists, relations: [], shows: shows, songs: [], timestamp: Date(),
        venues: venues))
  }

  func testDifferentDates() throws {
    let dateLater = PartialDate(year: date.year! + 1, month: 1, day: 15)

    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist2.id], date: dateLater, id: "sh1", venue: venue2.id)

    let vaultTest = createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = vaultTest.concertMap[show1.id]!
    let concert2 = vaultTest.concertMap[show2.id]!

    XCTAssertNotEqual(concert1, concert2)
    XCTAssertTrue(vaultTest.comparator.compare(lhs: concert1, rhs: concert2))
    XCTAssertFalse(vaultTest.comparator.compare(lhs: concert2, rhs: concert1))
  }

  func testSameDates_differentVenues() throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist2.id], date: date, id: "sh1", venue: venue2.id)

    let vaultTest = createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = vaultTest.concertMap[show1.id]!
    let concert2 = vaultTest.concertMap[show2.id]!

    XCTAssertNotEqual(concert1, concert2)
    XCTAssertFalse(vaultTest.comparator.compare(lhs: concert1, rhs: concert2))
    XCTAssertTrue(vaultTest.comparator.compare(lhs: concert2, rhs: concert1))
  }

  func testSameDates_sameVenues_differentArtists() throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist2.id], date: date, id: "sh1", venue: venue1.id)

    let vaultTest = createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = vaultTest.concertMap[show1.id]!
    let concert2 = vaultTest.concertMap[show2.id]!

    XCTAssertNotEqual(concert1, concert2)
    XCTAssertTrue(vaultTest.comparator.compare(lhs: concert1, rhs: concert2))
    XCTAssertFalse(vaultTest.comparator.compare(lhs: concert2, rhs: concert1))
  }

  func testSameDates_sameVenues_sameArtists() throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist1.id], date: date, id: "sh1", venue: venue1.id)

    let vaultTest = createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = vaultTest.concertMap[show1.id]!
    let concert2 = vaultTest.concertMap[show2.id]!

    XCTAssertNotEqual(concert1, concert2)
    XCTAssertTrue(vaultTest.comparator.compare(lhs: concert1, rhs: concert2))
    XCTAssertFalse(vaultTest.comparator.compare(lhs: concert2, rhs: concert1))
  }

  func testEdgeCase() throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = show1

    let vaultTest = createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = vaultTest.concertMap[show1.id]!
    let concert2 = vaultTest.concertMap[show2.id]!

    XCTAssertEqual(concert1, concert2)
    XCTAssertFalse(vaultTest.comparator.compare(lhs: concert1, rhs: concert2))
    XCTAssertFalse(vaultTest.comparator.compare(lhs: concert2, rhs: concert1))
  }
}
