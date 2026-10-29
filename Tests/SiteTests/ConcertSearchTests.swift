//
//  ConcertSearchTests.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/27/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct ConcertSearchTests {
  let chicago = Venue(id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
  let seattle = Venue(id: "v1", location: Location(city: "Seattle", state: "WA"), name: "V1")

  let pavement = Artist(id: "ar0", name: "Pavement")
  let slint = Artist(id: "ar1", name: "Slint")

  /// Pavement plays Chicago in 1996 and 1997 and Seattle in 1997. Slint plays Seattle in 1997.
  func createVault() async throws -> Vault {
    let shows = [
      Show(
        artists: [pavement.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
        venue: chicago.id),
      Show(
        artists: [pavement.id], date: PartialDate(year: 1997, month: 5, day: 1), id: "sh1",
        venue: chicago.id),
      Show(
        artists: [pavement.id, slint.id], date: PartialDate(year: 1997, month: 6, day: 2),
        id: "sh2", venue: seattle.id),
    ]
    return Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [pavement, slint], relations: [], shows: shows, songs: [],
            timestamp: Date(), venues: [chicago, seattle]),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
  }

  @Test func noPartMatchesEveryConcert() async throws {
    let vault = try await createVault()
    #expect(vault.concertEntities(matching: ConcertSearch()).count == 3)
  }

  @Test func artistNarrows() async throws {
    let vault = try await createVault()
    #expect(vault.concertEntities(matching: ConcertSearch(artistID: .artist(slint.id))).count == 1)
    #expect(
      vault.concertEntities(matching: ConcertSearch(artistID: .artist(pavement.id))).count == 3)
  }

  @Test func venueNarrows() async throws {
    let vault = try await createVault()
    #expect(vault.concertEntities(matching: ConcertSearch(venueID: .venue(chicago.id))).count == 2)
  }

  @Test func partsNarrowTogether() async throws {
    let vault = try await createVault()
    let search = ConcertSearch(artistID: .artist(pavement.id), venueID: .venue(chicago.id))
    #expect(vault.concertEntities(matching: search).count == 2)
  }

  @Test func dateIsOneDay() async throws {
    let vault = try await createVault()
    let date = try #require(
      Calendar.current.date(from: DateComponents(year: 1997, month: 5, day: 1)))
    #expect(vault.concertEntities(matching: ConcertSearch(date: date)).count == 1)
  }
}
