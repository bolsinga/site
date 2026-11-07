//
//  AtlasSourceTests.swift
//
//
//  Created by Greg Bolsinga on 11/7/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

/// Geocodes to a fixed place, from a source that can change.
private struct FixedGeocodable: AtlasGeocodable {
  let source: String
  let place: Int

  var geocodeSource: String? { source }

  func geocode() async throws -> Int { place }
}

struct AtlasSourceTests {
  private func removeCache(fileName: String) {
    _ = try? [ArchivePath: AtlasCache<FixedGeocodable>.Value].read(
      fileName: fileName, deleteFile: true)
  }

  private func withCache(
    _ body: (inout AtlasCache<FixedGeocodable>) async throws -> Void
  ) async throws {
    let fileName = "atlas-source-test-\(UUID().uuidString).json"
    defer { removeCache(fileName: fileName) }
    var cache = AtlasCache<FixedGeocodable>(fileName: fileName)
    try await body(&cache)
  }

  @Test func sameSourceIsCurrent() async throws {
    try await withCache { cache in
      let id = try ArchivePath(raw: "v1")
      cache.add(id, value: 1, source: "1 Main St")
      let cached = await Atlas(cache: cache).cached(
        FixedGeocodable(source: "1 Main St", place: 2), id: id)
      #expect(cached?.place == 1)
      #expect(cached?.isCurrent == true)
    }
  }

  @Test func changedSourceIsStale() async throws {
    try await withCache { cache in
      let id = try ArchivePath(raw: "v1")
      cache.add(id, value: 1, source: "1 Main St")
      let atlas = Atlas(cache: cache)
      let moved = FixedGeocodable(source: "2 Oak St", place: 2)
      #expect(await atlas.cached(moved, id: id)?.isCurrent == false)
      #expect(try await atlas.geocode(moved, id: id) == 2)
      #expect(await atlas.cached(moved, id: id)?.isCurrent == true)
    }
  }

  @Test func placeCachedWithoutSourceIsStale() async throws {
    try await withCache { cache in
      let id = try ArchivePath(raw: "v1")
      cache.add(id, value: 1)
      let cached = await Atlas(cache: cache).cached(
        FixedGeocodable(source: "1 Main St", place: 1), id: id)
      #expect(cached?.isCurrent == false)
    }
  }

  @Test func sourceIsSaved() async throws {
    let fileName = "atlas-source-test-\(UUID().uuidString).json"
    defer { removeCache(fileName: fileName) }
    let id = try ArchivePath(raw: "v1")
    var cache = AtlasCache<FixedGeocodable>(fileName: fileName)
    cache.add(id, value: 1, source: "1 Main St")
    #expect(AtlasCache<FixedGeocodable>(fileName: fileName).entry(id)?.source == "1 Main St")
  }

  @Test func batchShowsCachedPlacesThenRefreshesStaleOnes() async throws {
    try await withCache { cache in
      let current = try ArchivePath(raw: "v1")
      let moved = try ArchivePath(raw: "v2")
      let new = try ArchivePath(raw: "v3")
      cache.add(current, value: 10, source: "a")
      cache.add(moved, value: 20, source: "b")
      let geocodables = [
        (moved, FixedGeocodable(source: "b moved", place: 21)),
        (new, FixedGeocodable(source: "c", place: 30)),
        (current, FixedGeocodable(source: "a", place: 11)),
      ]

      var found = [(String, Int?)]()
      for try await (id, _, place) in BatchGeocode(
        atlas: Atlas(cache: cache), geocodables: geocodables)
      {
        found.append((id.formatted(), place))
      }
      #expect(found.map(\.0) == [moved, current, new, moved].map { $0.formatted() })
      #expect(found.map(\.1) == [20, 10, 30, 21])
    }
  }
}
