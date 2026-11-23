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
@testable import SiteCore

struct VaultProviderTests {
  private struct LoadFailure: Error {}

  /// Keeps the artists' names of each vault it loads.
  private func makeProvider(
    urlString: String,
    load: @escaping @Sendable (String, Lookup.LoadPolicy) async throws -> Vault
  ) -> VaultLoader<[String]> {
    VaultLoader(
      urlString: urlString, load: load,
      makeDerived: { $0.artistIDs().map(\.1.name) })
  }

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
    let provider = makeProvider(
      urlString: "https://www.example.com/json/shows.json",
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

  @Test func anIntentsLoadStartsFromTheSavedArchive() async throws {
    let vault = try await makeVault()
    let seen = Mutex<Lookup.LoadPolicy?>(nil)
    let provider = makeProvider(
      urlString: "https://www.example.com/json/shows.json",
      load: { _, policy in
        seen.withLock { $0 = policy }
        return vault
      })

    _ = try await provider.vault()

    #expect(seen.withLock { $0 } == .savedIfCurrent)
  }

  @Test func aVaultTheAppLoadedIsUsedWithoutLoading() async throws {
    let loads = Loads()
    let provider = makeProvider(
      urlString: "",
      load: { _, _ in
        loads.add()
        throw LoadFailure()
      })
    let vault = try await makeVault()

    await provider.use(vault)

    _ = try await provider.vault()
    #expect(try await provider.derived() == ["Pavement"])
    #expect(loads.count == 0)
  }

  @Test func aNewerVaultReplacesTheCatalogToo() async throws {
    let provider = makeProvider(
      urlString: "", load: { _, _ in throw LoadFailure() })

    await provider.use(try await makeVault(artistName: "Pavement"))
    await provider.use(try await makeVault(artistName: "Guided By Voices"))

    #expect(try await provider.derived() == ["Guided By Voices"])
  }

  @Test func aFailedLoadThrowsAndTheNextAskTriesAgain() async throws {
    let vault = try await makeVault()
    let loads = Loads()
    let provider = makeProvider(
      urlString: "",
      load: { _, _ in
        loads.add()
        if loads.count == 1 { throw LoadFailure() }
        return vault
      })

    await #expect(throws: LoadFailure.self) { try await provider.vault() }
    _ = try await provider.vault()

    #expect(loads.count == 2)
  }

  @Test func aLoadTheAppAsksForJoinsOneThatIsRunning() async throws {
    let vault = try await makeVault()
    let loads = Loads()
    let provider = makeProvider(
      urlString: "",
      load: { _, _ in
        loads.add()
        try await Task.sleep(for: .milliseconds(50))
        return vault
      })

    async let fromAnIntent = provider.vault()
    try await Task.sleep(for: .milliseconds(10))
    async let fromTheScene = provider.load(policy: .savedIfCurrent, joining: true)
    _ = try await (fromAnIntent, fromTheScene)

    #expect(loads.count == 1)
  }

  @Test func aLoadThatIsNotJoiningStartsItsOwn() async throws {
    let vault = try await makeVault()
    let loads = Loads()
    let provider = makeProvider(
      urlString: "",
      load: { _, _ in
        loads.add()
        try await Task.sleep(for: .milliseconds(50))
        return vault
      })

    async let fromAnIntent = provider.vault()
    try await Task.sleep(for: .milliseconds(10))
    async let refresh = provider.load(policy: .savedIfCurrent, joining: false)
    _ = try await (fromAnIntent, refresh)

    #expect(loads.count == 2)
  }

  @Test func theLoadThatStartedLastIsKeptWhateverOrderTheyFinishIn() async throws {
    let slowOldVault = try await makeVault(artistName: "Slow")
    let fastNewVault = try await makeVault(artistName: "Fast")
    let loads = Loads()
    let provider = makeProvider(
      urlString: "",
      load: { _, _ in
        loads.add()
        if loads.count == 1 {
          try await Task.sleep(for: .milliseconds(100))
          return slowOldVault
        }
        return fastNewVault
      })

    async let first = provider.vault()
    try await Task.sleep(for: .milliseconds(10))
    _ = try await provider.load(policy: .savedIfCurrent, joining: false)
    _ = try await first

    #expect(try await provider.derived() == ["Fast"])
  }

  @Test func aFailedLoadKeepsTheVaultThatWasLoaded() async throws {
    let provider = makeProvider(
      urlString: "", load: { _, _ in throw LoadFailure() })
    await provider.use(try await makeVault())

    await #expect(throws: LoadFailure.self) {
      try await provider.load(policy: .savedIfCurrent, joining: false)
    }

    #expect(try await provider.derived() == ["Pavement"])
  }
}
