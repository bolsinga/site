//
//  EntityCatalogTests.swift
//  SiteApp
//

import Foundation
import Testing
import os

@testable import Shared
@testable import SiteApp

struct EntityCatalogTests {
  private func vault() async throws -> Vault {
    let chicago = Venue(id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
    let seattle = Venue(id: "v1", location: Location(city: "Seattle", state: "WA"), name: "V1")
    let pavement = Artist(id: "ar0", name: "Pavement")
    let slint = Artist(id: "ar1", name: "Slint")
    let shows = [
      Show(
        artists: [pavement.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
        venue: chicago.id),
      Show(
        artists: [pavement.id, slint.id], date: PartialDate(year: 1997, month: 6, day: 2),
        id: "sh1", venue: seattle.id),
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

  @Test func makesAValueOnce() {
    let count = OSAllocatedUnfairLock(initialState: 0)
    let once = Once {
      count.withLock { count in
        count += 1
        return count
      }
    }

    #expect(count.withLock { $0 } == 0)
    #expect(once.value == 1)
    #expect(once.value == 1)
    #expect(count.withLock { $0 } == 1)
  }

  @Test func makesEachKindOnlyWhenAskedForAndOnlyOnce() {
    let counts = OSAllocatedUnfairLock(initialState: [String: Int]())
    func counted<Entity: Sendable>(_ kind: String) -> @Sendable () -> [Entity] {
      {
        counts.withLock { $0[kind, default: 0] += 1 }
        return []
      }
    }
    let catalog = EntityCatalog(
      artists: counted("artists"), venues: counted("venues"), concerts: counted("concerts"),
      cities: counted("cities"))

    #expect(counts.withLock { $0.isEmpty })
    _ = catalog.artists
    _ = catalog.artists
    _ = catalog.cities
    #expect(counts.withLock { $0 } == ["artists": 1, "cities": 1])
  }

  @Test func holdsTheEntitiesOfTheVault() async throws {
    let vault = try await vault()
    let catalog = EntityCatalog(vault: vault)

    #expect(Set(catalog.artists.map(\.id)) == Set(vault.artistEntities.map(\.id)))
    #expect(Set(catalog.venues.map(\.id)) == Set(vault.venueEntities.map(\.id)))
    #expect(Set(catalog.concerts.map(\.id)) == Set(vault.concertEntities.map(\.id)))
    #expect(catalog.cities.map(\.id) == ["Chicago, IL", "Seattle, WA"])
    #expect(catalog.concerts.count == 2)
  }

  @Test func aNewCatalogMakesThemAgain() {
    let count = OSAllocatedUnfairLock(initialState: 0)
    func catalog() -> EntityCatalog {
      EntityCatalog(
        artists: {
          count.withLock { $0 += 1 }
          return []
        }, venues: { [] }, concerts: { [] }, cities: { [] })
    }

    _ = catalog().artists
    _ = catalog().artists
    #expect(count.withLock { $0 } == 2)
  }
}
