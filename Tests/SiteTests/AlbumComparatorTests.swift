//
//  AlbumComparatorTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import XCTest

@testable import Site

final class AlbumComparatorTests: XCTestCase {
  let aTitle = "Atlas"
  let bTitle = "Banana"

  let unknownDate = PartialDate()
  let date = PartialDate(year: 1996)

  let artist1 = Artist(id: "ar0", name: "A Artist")
  let artist2 = Artist(id: "ar1", name: "B Artist")

  func createVault(albums: [Album], artists: [Artist]) -> Vault {
    Vault(
      music: Music(
        albums: albums, artists: artists, relations: [], shows: [], songs: [], timestamp: Date(),
        venues: []))
  }

  func testUnknownRelease_UnknownRelease() throws {
    let album1 = Album(id: "a0", performer: artist1.id, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, songs: [], title: bTitle)

    let vault = createVault(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testUnknownRelease_fullDate() throws {
    let album1 = Album(id: "a0", performer: artist1.id, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, release: date, songs: [], title: bTitle)

    let vault = createVault(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testFullDate_fullDate() throws {
    let album1 = Album(
      id: "a0", performer: artist1.id, release: PartialDate(year: date.year! - 1), songs: [],
      title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, release: date, songs: [], title: bTitle)

    let vault = createVault(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_knownArtists() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, release: date, songs: [], title: bTitle)

    let vault = createVault(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_oneUnknownArtists() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", release: date, songs: [], title: bTitle)

    let vault = createVault(albums: [album1, album2], artists: [artist1])

    XCTAssertNotEqual(album1, album2)
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_twoUnknownArtists() throws {
    let album1 = Album(id: "a0", release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", release: date, songs: [], title: bTitle)

    let vault = createVault(albums: [album1, album2], artists: [])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_sameArtists() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist1.id, release: date, songs: [], title: bTitle)

    let vault = createVault(albums: [album1, album2], artists: [artist1])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_sameArtists_sameTitle() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist1.id, release: date, songs: [], title: aTitle)

    let vault = createVault(albums: [album1, album2], artists: [artist1])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }

  func testEquality() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = album1

    let vault = createVault(albums: [album1, album2], artists: [artist1])

    XCTAssertEqual(album1, album2)
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(vault.lookup.albumCompare(lhs: album2, rhs: album1))
  }
}
