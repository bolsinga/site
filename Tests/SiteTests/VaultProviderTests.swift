//
//  VaultProviderTests.swift
//  site
//
//  Created by Greg Bolsinga on 11/20/26.
//

import Foundation
import Synchronization
import Testing

@testable import Shared
@testable import SiteApp

struct VaultProviderTests {
  private struct LoadFailure: Error {}

  private func makeVault(artistName: String = "Pavement") async throws -> Vault {
    let venue = Venue(id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
    let artist = Artist(id: "ar0", name: artistName)
    let show = Show(
      artists: [artist.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
      venue: venue.id)
    let music = Music(
      albums: [], artists: [artist], relations: [], shows: [show], songs: [],
      timestamp: Date(), venues: [venue])
    return Vault(
      lookup: try await Lookup(bracket: try await Bracket(music: music, timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
  }

  private final class Loads: Sendable {
    private let counter = Mutex(0)
    var count: Int { counter.withLock { $0 } }
    func add() { counter.withLock { $0 += 1 } }
  }

  @Test func askingLoadsTheVaultOnce() async throws {
    let vault = try await makeVault()
    let loads = Loads()
    let provider = VaultProvider(
      urlString: "https://www.example.com/json/shows.json", previousModified: { .distantPast },
      load: { _, _ in
        loads.add()
        try await Task.sleep(for: .milliseconds(50))
        return vault
      })

    async let first = provider.vault()
    async let second = provider.vault()
    _ = try await (first, second)
    _ = try await provider.vault()

    #expect(loads.count == 1)
  }

  @Test func theLoadIsGivenTheStoredDate() async throws {
    let vault = try await makeVault()
    let stored = Date(timeIntervalSince1970: 1_000_000)
    let seen = Mutex<Date?>(nil)
    let provider = VaultProvider(
      urlString: "https://www.example.com/json/shows.json", previousModified: { stored },
      load: { _, date in
        seen.withLock { $0 = date }
        return vault
      })

    _ = try await provider.vault()

    #expect(seen.withLock { $0 } == stored)
  }

  @Test func aVaultTheAppLoadedIsUsedWithoutLoading() async throws {
    let loads = Loads()
    let provider = VaultProvider(
      urlString: "", previousModified: { .distantPast },
      load: { _, _ in
        loads.add()
        throw LoadFailure()
      })
    let vault = try await makeVault()

    await provider.use(vault)

    _ = try await provider.vault()
    #expect(try await provider.catalog().artists.map(\.name) == ["Pavement"])
    #expect(loads.count == 0)
  }

  @Test func aNewerVaultReplacesTheCatalogToo() async throws {
    let provider = VaultProvider(
      urlString: "", previousModified: { .distantPast }, load: { _, _ in throw LoadFailure() })

    await provider.use(try await makeVault(artistName: "Pavement"))
    await provider.use(try await makeVault(artistName: "Guided By Voices"))

    #expect(try await provider.catalog().artists.map(\.name) == ["Guided By Voices"])
  }

  @Test func aFailedLoadThrowsAndTheNextAskTriesAgain() async throws {
    let vault = try await makeVault()
    let loads = Loads()
    let provider = VaultProvider(
      urlString: "", previousModified: { .distantPast },
      load: { _, _ in
        loads.add()
        if loads.count == 1 { throw LoadFailure() }
        return vault
      })

    await #expect(throws: LoadFailure.self) { try await provider.vault() }
    _ = try await provider.vault()

    #expect(loads.count == 2)
  }
}
