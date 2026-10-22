//
//  VaultStatisticsTests.swift
//
//
//  Created by Greg Bolsinga on 10/21/26.
//

import Foundation
import Testing

@testable import Shared

struct VaultStatisticsTests {
  let venue1 = Venue(id: "v0", location: Location(city: "city", state: "CA"), name: "A Venue")
  let venue2 = Venue(id: "v1", location: Location(city: "city", state: "IL"), name: "B Venue")

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

  @Test func statisticsOfSomeVenues() async throws {
    let shows = [
      Show(
        artists: [artist1.id], date: PartialDate(year: 1996, month: 12, day: 15), id: "sh0",
        venue: venue1.id),
      Show(
        artists: [artist1.id, artist2.id], date: PartialDate(year: 1997, month: 1, day: 2),
        id: "sh1", venue: venue1.id),
      Show(
        artists: [artist2.id], date: PartialDate(year: 2001, month: 5, day: 6), id: "sh2",
        venue: venue2.id),
    ]
    let vault = try await createVault(
      artists: [artist1, artist2], shows: shows, venues: [venue1, venue2])

    let venueIDs = vault.venueIDs().filter { $0.1.id == venue1.id }.map { $0.0 }
    let data = vault.statisticsData(venueIDs: venueIDs)
    #expect(data.showsCount == 2)
    #expect(data.venueCount == 1)
    #expect(data.artistCount == 2)
    #expect(data.dates.count == 2)
    #expect(data.states == ["CA": 2])

    let all = vault.statisticsData
    #expect(all.showsCount == 3)
    #expect(all.states == ["CA": 2, "IL": 1])
  }

  @Test func statisticsOfNoVenues() async throws {
    let vault = try await createVault(artists: [artist1], shows: [], venues: [venue1])
    let data = vault.statisticsData(venueIDs: [])
    #expect(data.showsCount == 0)
    #expect(data.venueCount == 0)
    #expect(data.artistCount == 0)
    #expect(data.dates.isEmpty)
    #expect(data.states.isEmpty)
  }
}
