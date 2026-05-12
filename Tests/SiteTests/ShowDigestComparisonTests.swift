//
//  ShowDigestComparisonTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import Foundation
import Testing

@testable import SiteApp

struct ShowDigestComparisonTests {
  let date = PartialDate(year: 1996, month: 12, day: 15)

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
          identifier: ArchivePathIdentifier())),
      rootURL: URL(string: "https://www.example.com/")!)
  }

  @Test func differentDates() async throws {
    let dateLater = PartialDate(year: date.year! + 1, month: 1, day: 15)

    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist2.id], date: dateLater, id: "sh1", venue: venue2.id)

    let vaultTest = try await createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = try #require(vaultTest.digest(show: show1.archivePath))
    let concert2 = try #require(vaultTest.digest(show: show2.archivePath))

    #expect(concert1 != concert2)

    let sorted = try vaultTest.sort(showIDs: [concert1.id, concert2.id].shuffled())
    #expect(sorted.count == 2)
    #expect(try #require(sorted.first) == concert1.id)
    #expect(try #require(sorted.last) == concert2.id)
  }

  @Test func sameDates_differentVenues() async throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist2.id], date: date, id: "sh1", venue: venue2.id)

    let vaultTest = try await createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = try #require(vaultTest.digest(show: show1.archivePath))
    let concert2 = try #require(vaultTest.digest(show: show2.archivePath))

    #expect(concert1 != concert2)

    let sorted = try vaultTest.sort(showIDs: [concert1.id, concert2.id].shuffled())
    #expect(sorted.count == 2)
    #expect(try #require(sorted.first) == concert2.id)
    #expect(try #require(sorted.last) == concert1.id)
  }

  @Test func sameDates_sameVenues_differentArtists() async throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist2.id], date: date, id: "sh1", venue: venue1.id)

    let vaultTest = try await createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = try #require(vaultTest.digest(show: show1.archivePath))
    let concert2 = try #require(vaultTest.digest(show: show2.archivePath))

    #expect(concert1 != concert2)

    let sorted = try vaultTest.sort(showIDs: [concert1.id, concert2.id].shuffled())
    #expect(sorted.count == 2)
    #expect(try #require(sorted.first) == concert1.id)
    #expect(try #require(sorted.last) == concert2.id)
  }

  @Test func sameDates_sameVenues_sameArtists() async throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = Show(artists: [artist1.id], date: date, id: "sh1", venue: venue1.id)

    let vaultTest = try await createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = try #require(vaultTest.digest(show: show1.archivePath))
    let concert2 = try #require(vaultTest.digest(show: show2.archivePath))

    #expect(concert1 != concert2)

    let sorted = try vaultTest.sort(showIDs: [concert1.id, concert2.id].shuffled())
    #expect(sorted.count == 2)
    #expect(try #require(sorted.first) == concert1.id)
    #expect(try #require(sorted.last) == concert2.id)
  }

  @Test func edgeCase() async throws {
    let show1 = Show(artists: [artist1.id], date: date, id: "sh0", venue: venue1.id)
    let show2 = show1

    let vaultTest = try await createVault(
      artists: [artist1, artist2], shows: [show1, show2], venues: [venue1, venue2])

    let concert1 = try #require(vaultTest.digest(show: show1.archivePath))
    let concert2 = try #require(vaultTest.digest(show: show2.archivePath))

    #expect(concert1 == concert2)

    let sorted = try vaultTest.sort(showIDs: [concert1.id, concert2.id].shuffled())
    #expect(sorted.count == 2)
    #expect(try #require(sorted.first) == concert2.id)
    #expect(try #require(sorted.last) == concert1.id)
  }
}
