//
//  ShowsTodaySnapshotTests.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation
import Testing

@testable import Shared

struct ShowsTodaySnapshotTests {
  let venue1 = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "A Venue")
  let venue2 = Venue(id: "v1", location: Location(city: "city", state: "CA"), name: "B Venue")

  let artist1 = Artist(id: "ar0", name: "A Artist")
  let artist2 = Artist(id: "ar1", name: "B Artist")

  func createVault(artists: [Artist], shows: [Show], venues: [Venue]) async throws
    -> Vault<ArchivePathIdentifier>
  {
    Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [],
            artists: artists,
            relations: [],
            shows: shows,
            songs: [],
            timestamp: Date(),
            venues: venues),
          identifier: ArchivePathIdentifier(),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
  }

  @Test func snapshotMatchesConcertsOnDay() async throws {
    let date = PartialDate(year: 1996, month: 12, day: 15)
    let show = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)

    let vault = try await createVault(artists: [artist1], shows: [show], venues: [venue1])
    let snapshot = try vault.showsTodaySnapshot

    let dayOfLeapYear = try #require(date.date).dayOfLeapYear
    #expect(snapshot.shows(on: dayOfLeapYear) == (try vault.concerts(on: dayOfLeapYear)))
  }

  @Test func daysWithoutShowsAreAbsent() async throws {
    let date = PartialDate(year: 1996, month: 12, day: 15)
    let show = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)

    let vault = try await createVault(artists: [artist1], shows: [show], venues: [venue1])
    let snapshot = try vault.showsTodaySnapshot

    let dayOfLeapYear = try #require(date.date).dayOfLeapYear
    let otherDay = dayOfLeapYear == 1 ? 2 : 1
    #expect(snapshot.shows(on: otherDay).isEmpty)
    #expect(snapshot.days[otherDay] == nil)
  }

  @Test func multipleShowsOnSameDay() async throws {
    let date = PartialDate(year: 1996, month: 12, day: 15)
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist2.id], date: date, id: "sh1", venue: venue2.id)

    let vault = try await createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])
    let snapshot = try vault.showsTodaySnapshot

    let dayOfLeapYear = try #require(date.date).dayOfLeapYear
    #expect(snapshot.shows(on: dayOfLeapYear).count == 2)
  }

  @Test func roundTripsThroughJSON() throws {
    let show = ShowDigest(
      id: Show(
        artists: ["ar0"], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: "v0"
      ).archivePath,
      date: PartialDate(year: 1996, month: 12, day: 15),
      performers: [ArchiveItem(id: ArchivePath.artist("ar0"), name: "A Artist")],
      venue: "A Venue",
      location: Location(city: "city", state: "CA"),
      comment: nil)

    let snapshot = ShowsTodaySnapshot(
      generated: Date(timeIntervalSince1970: 0), days: [349: [show]])

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(snapshot)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let decoded = try decoder.decode(ShowsTodaySnapshot.self, from: data)

    #expect(decoded == snapshot)
  }
}
