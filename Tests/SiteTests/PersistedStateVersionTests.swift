//
//  PersistedStateVersionTests.swift
//  SiteApp
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp
@testable import SiteCore

private struct NumberGeocodable: AtlasGeocodable {
  func geocode() async throws -> Int { 1 }
}

struct PersistedStateVersionTests {
  @Test func savedNavigationRoundTrips() throws {
    let state = ArchiveNavigation.State(
      category: .venues, showsPath: [.show("sh1")], venuesPath: [.venue("v1")])

    #expect(ArchiveNavigation.State(jsonString: state.jsonString) == state)
  }

  @Test func unreadablePathsAreDroppedAndTheRestKept() throws {
    let show = ArchivePath.show("sh1").formatted(.json)
    let venue = ArchivePath.venue("v1").formatted(.json)
    let json = """
      {"category":"venues","showsPath":["\(show)","nonsense"],"venuesPath":["\(venue)"]}
      """

    let state = try #require(ArchiveNavigation.State(jsonString: json))

    #expect(
      state
        == ArchiveNavigation.State(
          category: .venues, showsPath: [.show("sh1")], venuesPath: [.venue("v1")]))
  }

  @Test func missingFieldsFallBackToTheirDefaults() throws {
    let state = try #require(ArchiveNavigation.State(jsonString: #"{"category":"artists"}"#))

    #expect(state == ArchiveNavigation.State(category: .artists))
  }

  @Test func anUnknownCategoryFallsBackToTheDefault() throws {
    let state = try #require(ArchiveNavigation.State(jsonString: #"{"category":"podcasts"}"#))

    #expect(state.category == .defaultCategory)
  }

  @Test func atlasFileIsNamedByItsVersion() {
    #expect(atlasFileName(version: 1) == "atlas.json")
    #expect(atlasFileName(version: 2) == "atlas-2.json")
    #expect(atlasFileName() == atlasFileName(version: atlasCacheVersion))
  }

  @Test func savingAtlasRemovesTheOlderVersionsFiles() throws {
    let store = InMemoryCache()
    try store.put([String: Int](), fileName: atlasFileName(version: 1))
    try store.put([String: Int](), fileName: atlasFileName(version: 2))
    var cache = AtlasCache<NumberGeocodable>(version: 3, store: store)

    cache.add(try ArchivePath(raw: "v1"), value: 1)

    #expect(store.contains(fileName: atlasFileName(version: 3)))
    #expect(!store.contains(fileName: atlasFileName(version: 1)))
    #expect(!store.contains(fileName: atlasFileName(version: 2)))
  }
}
