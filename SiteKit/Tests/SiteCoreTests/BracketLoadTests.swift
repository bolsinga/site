//
//  BracketLoadTests.swift
//  SiteApp
//

import Foundation
import SiteTestSupport
import Synchronization
import Testing

@testable import SiteCore

struct BracketLoadTests {
  private struct NetworkFailure: Error {}

  private let url = URL(string: "https://www.example.com/json/shows.json")!
  private let old = Date(timeIntervalSince1970: 1_000_000)
  private let new = Date(timeIntervalSince1970: 2_000_000)

  private func bracket(artistName: String, timestamp: Date) async throws -> Bracket {
    let venue = Venue(id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
    let artist = Artist(id: "ar0", name: artistName)
    let show = Show(
      artists: [artist.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
      venue: venue.id)
    return try await Bracket(
      music: Music(
        albums: [], artists: [artist], relations: [], shows: [show], songs: [],
        timestamp: timestamp,
        venues: [venue]),
      timestamp: timestamp)
  }

  /// Counts the asks of the network, and answers them.
  private final class Network: Sendable {
    private struct State {
      var checkedSince = [Date]()
      var downloads = 0
    }
    private let state = Mutex(State())
    let updated: Bool?
    let download: Bracket?

    /// `updated` is nil when the `HEAD` fails, and `download` is nil when the download fails.
    init(updated: Bool?, download: Bracket?) {
      self.updated = updated
      self.download = download
    }

    var checkedSince: [Date] { state.withLock { $0.checkedSince } }
    var downloads: Int { state.withLock { $0.downloads } }

    func isUpdated(_: URL, since date: Date) throws -> Bool {
      state.withLock { $0.checkedSince.append(date) }
      guard let updated else { throw NetworkFailure() }
      return updated
    }

    func downloadBracket(_: URL) throws -> Bracket {
      state.withLock { $0.downloads += 1 }
      guard let download else { throw NetworkFailure() }
      return download
    }
  }

  private func load(
    _ policy: Lookup.LoadPolicy, store: InMemoryCache, network: Network
  ) async throws -> Bracket {
    try await Lookup.bracket(
      url: url, policy: policy, store: store,
      isUpdated: { try network.isUpdated($0, since: $1) },
      download: { try network.downloadBracket($0) })
  }

  private func names(_ bracket: Bracket) -> [String] {
    bracket.artistMap.values.map(\.name)
  }

  @Test func aSavedCopyTheServerHasNothingNewerThanIsUsed() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let network = Network(updated: false, download: nil)

    let result = try await load(.savedIfCurrent, store: store, network: network)

    #expect(names(result) == ["Saved"])
    #expect(network.checkedSince == [old])
    #expect(network.downloads == 0)
  }

  @Test func theServerIsAskedAboutTheDateOfTheSavedCopy() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: new).save(store: store)
    let network = Network(updated: false, download: nil)

    _ = try await load(.savedIfCurrent, store: store, network: network)

    #expect(network.checkedSince == [new])
  }

  @Test func aNewerArchiveIsDownloadedAndSaved() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let network = Network(
      updated: true, download: try await bracket(artistName: "Downloaded", timestamp: new))

    let result = try await load(.savedIfCurrent, store: store, network: network)

    #expect(names(result) == ["Downloaded"])
    #expect(try Bracket.read(store: store).timestamp == new)
  }

  @Test func withNoSavedCopyTheArchiveIsDownloadedWithoutAsking() async throws {
    let store = InMemoryCache()
    let network = Network(
      updated: false, download: try await bracket(artistName: "Downloaded", timestamp: new))

    let result = try await load(.savedIfCurrent, store: store, network: network)

    #expect(names(result) == ["Downloaded"])
    #expect(network.checkedSince.isEmpty)
    #expect(store.contains(fileName: bracketFileName()))
  }

  @Test func aSavedCopyIsUsedWhenTheServerCantBeAsked() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let network = Network(updated: nil, download: nil)

    let result = try await load(.savedIfCurrent, store: store, network: network)

    #expect(names(result) == ["Saved"])
    #expect(network.downloads == 0)
  }

  @Test func aSavedCopyIsUsedWhenTheDownloadOfANewerOneFails() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let network = Network(updated: true, download: nil)

    let result = try await load(.savedIfCurrent, store: store, network: network)

    #expect(names(result) == ["Saved"])
    #expect(network.downloads == 1)
  }

  @Test func withNoSavedCopyAFailedDownloadIsAnError() async throws {
    let store = InMemoryCache()
    let network = Network(updated: false, download: nil)

    await #expect(throws: NetworkFailure.self) {
      try await load(.savedIfCurrent, store: store, network: network)
    }
  }

  @Test func downloadingIgnoresTheSavedCopyThatIsCurrent() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let network = Network(
      updated: false, download: try await bracket(artistName: "Downloaded", timestamp: new))

    let result = try await load(.download, store: store, network: network)

    #expect(names(result) == ["Downloaded"])
    #expect(network.checkedSince.isEmpty)
    #expect(try Bracket.read(store: store).timestamp == new)
  }

  @Test func downloadingFallsBackToTheSavedCopyWhenItFails() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let network = Network(updated: false, download: nil)

    let result = try await load(.download, store: store, network: network)

    #expect(names(result) == ["Saved"])
  }

  @Test func downloadingWithNothingSavedAndAFailureIsAnError() async throws {
    let store = InMemoryCache()
    let network = Network(updated: false, download: nil)

    await #expect(throws: NetworkFailure.self) {
      try await load(.download, store: store, network: network)
    }
  }

  @Test func uncachedDownloadsWithoutReadingOrWritingTheSavedCopy() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let savesBefore = store.saves
    let removalsBefore = store.removals
    let network = Network(
      updated: false, download: try await bracket(artistName: "Downloaded", timestamp: new))

    let result = try await load(.uncached, store: store, network: network)

    #expect(names(result) == ["Downloaded"])
    #expect(network.checkedSince.isEmpty)
    #expect(store.reads.isEmpty)
    #expect(store.saves == savesBefore)
    #expect(store.removals == removalsBefore)
    #expect(try Bracket.read(store: store).timestamp == old)
  }

  @Test func uncachedDoesNotFallBackToTheSavedCopy() async throws {
    let store = InMemoryCache()
    try await bracket(artistName: "Saved", timestamp: old).save(store: store)
    let network = Network(updated: false, download: nil)

    await #expect(throws: NetworkFailure.self) {
      try await load(.uncached, store: store, network: network)
    }
  }
}
