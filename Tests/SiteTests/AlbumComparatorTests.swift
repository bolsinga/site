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

  func createMusic(albums: [Album], artists: [Artist]) -> Music {
    Music(
      albums: albums, artists: artists, relations: [], shows: [], songs: [], timestamp: Date(),
      venues: [])
  }

  func testUnknownRelease_UnknownRelease() throws {
    let album1 = Album(id: "a0", performer: artist1.id, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, songs: [], title: bTitle)

    let music = createMusic(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    XCTExpectFailure("albums with identical unknown dates should sort by artist.") {
      XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
    }
  }

  func testUnknownRelease_fullDate() throws {
    let album1 = Album(id: "a0", performer: artist1.id, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, release: date, songs: [], title: bTitle)

    let music = createMusic(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
  }

  func testFullDate_fullDate() throws {
    let album1 = Album(
      id: "a0", performer: artist1.id, release: PartialDate(year: date.year! - 1), songs: [],
      title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, release: date, songs: [], title: bTitle)

    let music = createMusic(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_knownArtists() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist2.id, release: date, songs: [], title: bTitle)

    let music = createMusic(albums: [album1, album2], artists: [artist1, artist2])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_oneUnknownArtists() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", release: date, songs: [], title: bTitle)

    let music = createMusic(albums: [album1, album2], artists: [artist1])

    XCTAssertNotEqual(album1, album2)
    XCTExpectFailure("album with performer should come before album without.") {
      XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    }
    XCTExpectFailure("album with performer should come before album without.") {
      XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
    }
  }

  func testSameDates_twoUnknownArtists() throws {
    let album1 = Album(id: "a0", release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", release: date, songs: [], title: bTitle)

    let music = createMusic(albums: [album1, album2], artists: [])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    XCTExpectFailure("albums without performers sort by album title.") {
      XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
    }
  }

  func testSameDates_sameArtists() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist1.id, release: date, songs: [], title: bTitle)

    let music = createMusic(albums: [album1, album2], artists: [artist1])

    XCTAssertNotEqual(album1, album2)
    XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
  }

  func testSameDates_sameArtists_sameTitle() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = Album(id: "a1", performer: artist1.id, release: date, songs: [], title: aTitle)

    let music = createMusic(albums: [album1, album2], artists: [artist1])

    XCTAssertNotEqual(album1, album2)
    XCTExpectFailure(
      "albums with identical performer, date, title, should fallback to sort by album id."
    ) {
      XCTAssertTrue(music.albumCompare(lhs: album1, rhs: album2))
    }
    XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
  }

  func testEquality() throws {
    let album1 = Album(id: "a0", performer: artist1.id, release: date, songs: [], title: aTitle)
    let album2 = album1

    let music = createMusic(albums: [album1, album2], artists: [artist1])

    XCTAssertEqual(album1, album2)
    XCTAssertFalse(music.albumCompare(lhs: album1, rhs: album2))
    XCTAssertFalse(music.albumCompare(lhs: album2, rhs: album1))
  }
}
