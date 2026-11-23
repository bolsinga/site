//
//  EntityCatalogTests.swift
//  SiteApp
//

import Foundation
import Synchronization
import Testing

@testable import Shared
@testable import SiteApp
@testable import SiteCore

/// Counts how many times something was made, from closures that outlive the test's stack.
private final class Counts: Sendable {
  private let counts = Mutex([String: Int]())

  var values: [String: Int] { counts.withLock { $0 } }

  func increment(_ kind: String) {
    counts.withLock { $0[kind, default: 0] += 1 }
  }
}

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

  @Test func makesEachKindOnlyWhenAskedForAndOnlyOnce() {
    let counts = Counts()
    func counted<Entity: Sendable>(_ kind: String) -> @Sendable () -> [Entity] {
      {
        counts.increment(kind)
        return []
      }
    }
    let catalog = EntityCatalog(
      artists: counted("artists"), venues: counted("venues"), concerts: counted("concerts"),
      cities: counted("cities"))

    #expect(counts.values.isEmpty)
    _ = catalog.artists
    _ = catalog.artists
    _ = catalog.cities
    #expect(counts.values == ["artists": 1, "cities": 1])
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
    let counts = Counts()
    func catalog() -> EntityCatalog {
      EntityCatalog(
        artists: {
          counts.increment("artists")
          return []
        }, venues: { [] }, concerts: { [] }, cities: { [] })
    }

    _ = catalog().artists
    _ = catalog().artists
    #expect(counts.values == ["artists": 2])
  }
}
