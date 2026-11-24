//
//  BracketCacheTests.swift
//  SiteApp
//

import Foundation
import SiteTestSupport
import Testing

@testable import SiteCore

struct BracketCacheTests {
  private func bracket() async throws -> Bracket {
    let venue = Venue(id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
    let artist = Artist(id: "ar0", name: "Pavement")
    let show = Show(
      artists: [artist.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
      venue: venue.id)
    return try await Bracket(
      music: Music(
        albums: [], artists: [artist], relations: [], shows: [show], songs: [], timestamp: Date(),
        venues: [venue]),
      timestamp: .now)
  }

  private var olderFileNames: [String] {
    (1..<bracketCacheVersion).map { bracketFileName(version: $0) }
  }

  @Test func savesUnderTheCurrentNameAndRemovesOlderVersions() async throws {
    let store = InMemoryCache()

    #expect(try await bracket().saveIfPossible(store: store))

    #expect(store.saves == [bracketFileName()])
    #expect(store.removals == olderFileNames)
    #expect(store.contains(fileName: bracketFileName()))
  }

  @Test func aSavedBracketReadsBack() async throws {
    let store = InMemoryCache()
    let bracket = try await bracket()
    try bracket.save(store: store)

    let read = try Bracket.read(store: store)

    #expect(Set(read.showMap.keys) == Set(bracket.showMap.keys))
    #expect(store.reads == [bracketFileName()])
  }

  @Test func aFailedSaveIsNotAnError() async throws {
    let store = InMemoryCache()
    store.failSaves()
    let bracket = try await bracket()

    #expect(throws: InMemoryCache.Failure.self) { try bracket.save(store: store) }
    #expect(!bracket.saveIfPossible(store: store))
  }

  @Test func aFailedSaveRemovesTheOlderSavedBracket() async throws {
    let store = InMemoryCache()
    let bracket = try await bracket()
    try bracket.save(store: store)
    store.failSaves()

    #expect(!bracket.saveIfPossible(store: store))

    #expect(!store.contains(fileName: bracketFileName()))
    #expect(throws: (any Error).self) { try Bracket.read(store: store) }
  }
}
