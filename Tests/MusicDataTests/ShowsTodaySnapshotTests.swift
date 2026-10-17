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

  func sampleSnapshot() -> ShowsTodaySnapshot {
    let show = ShowDigest(
      id: .show("sh0"),
      date: PartialDate(year: 1996, month: 12, day: 15),
      performers: [ArchiveItem(id: .artist("ar0"), name: "A Artist")],
      venue: "A Venue",
      location: Location(city: "city", state: "CA"),
      comment: nil)
    return ShowsTodaySnapshot(generated: Date(timeIntervalSince1970: 0), days: [350: [show]])
  }

  func digest(_ id: String, year: Int?) -> ShowDigest {
    ShowDigest(
      id: .show(id),
      date: PartialDate(year: year, month: 1, day: 1),
      performers: [ArchiveItem(id: .artist("ar0"), name: "A Artist")],
      venue: "A Venue",
      location: Location(city: "city", state: "CA"),
      comment: nil)
  }

  @Test func earliestYearSpansAllDays() {
    let snapshot = ShowsTodaySnapshot(
      days: [
        1: [digest("a", year: 2001), digest("b", year: nil)],
        200: [digest("c", year: 1988)],
        350: [digest("d", year: 1996)],
      ])
    #expect(snapshot.earliestYear == 1988)
  }

  @Test func earliestYearIsNilWithoutKnownYears() {
    #expect(ShowsTodaySnapshot(days: [:]).earliestYear == nil)
    #expect(ShowsTodaySnapshot(days: [1: [digest("a", year: nil)]]).earliestYear == nil)
  }

  func temporaryFileURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
      .appendingPathComponent("shows-today.json", isDirectory: false)
  }

  @Test func snapshotContainsShowOnItsDay() async throws {
    let date = PartialDate(year: 1996, month: 12, day: 15)
    let show = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)

    let vault = try await createVault(artists: [artist1], shows: [show], venues: [venue1])
    let snapshot = try vault.showsTodaySnapshot

    let dayOfLeapYear = try #require(date.date).dayOfLeapYear
    #expect(snapshot.days.keys.sorted() == [dayOfLeapYear])

    let digest = try #require(snapshot.shows(on: dayOfLeapYear).first)
    #expect(snapshot.shows(on: dayOfLeapYear).count == 1)
    #expect(digest.date == date)
    #expect(digest.venue == venue1.name)
    #expect(digest.performerNames == [artist1.name])
  }

  @Test func showsWithUnknownDaysAreAbsent() async throws {
    let show = Show(
      artists: [artist1.id], date: PartialDate(year: 1996, month: 12), id: "sh0", venue: venue1.id)

    let vault = try await createVault(artists: [artist1], shows: [show], venues: [venue1])
    let snapshot = try vault.showsTodaySnapshot

    #expect(snapshot.days.isEmpty)
  }

  @Test func multipleShowsOnSameDayAreOldestFirst() async throws {
    let newer = Show(
      artists: [artist2.id], date: PartialDate(year: 2001, month: 12, day: 15), id: "sh1",
      venue: venue2.id)
    let older = Show(
      artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
      venue: venue1.id)

    let vault = try await createVault(
      artists: [artist1, artist2], shows: [newer, older], venues: [venue1, venue2])
    let snapshot = try vault.showsTodaySnapshot

    let dayOfLeapYear = try #require(older.date.date).dayOfLeapYear
    #expect(snapshot.days.count == 1)
    #expect(snapshot.shows(on: dayOfLeapYear).map { $0.date.year } == [1996, 2001])
  }

  @Test func writeThenReadRoundTrips() throws {
    let fileURL = temporaryFileURL()
    defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }

    let snapshot = sampleSnapshot()
    #expect(try snapshot.write(to: fileURL))
    #expect(ShowsTodaySnapshot.read(from: fileURL) == snapshot)
  }

  @Test func unchangedSnapshotIsNotRewritten() throws {
    let fileURL = temporaryFileURL()
    defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }

    #expect(try sampleSnapshot().write(to: fileURL))
    #expect(try sampleSnapshot().write(to: fileURL) == false)
  }

  @Test func changedSnapshotIsRewritten() throws {
    let fileURL = temporaryFileURL()
    defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }

    #expect(try sampleSnapshot().write(to: fileURL))
    // ISO 8601 drops fractional seconds, so use a whole-second date to compare after reading.
    let changed = ShowsTodaySnapshot(generated: Date(timeIntervalSince1970: 1_000), days: [:])
    #expect(try changed.write(to: fileURL))
    #expect(ShowsTodaySnapshot.read(from: fileURL) == changed)
  }

  @Test func mismatchedVersionIsIgnored() throws {
    let fileURL = temporaryFileURL()
    defer { try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent()) }

    var json = try #require(
      try JSONSerialization.jsonObject(with: sampleSnapshot().encoded()) as? [String: Any])
    json["version"] = ShowsTodaySnapshot.currentVersion + 1
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try JSONSerialization.data(withJSONObject: json).write(to: fileURL)

    #expect(ShowsTodaySnapshot.read(from: fileURL) == nil)
  }

  @Test func missingFileReadsAsNil() {
    #expect(ShowsTodaySnapshot.read(from: temporaryFileURL()) == nil)
  }
}
