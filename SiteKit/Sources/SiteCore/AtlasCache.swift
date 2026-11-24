//
//  AtlasCache.swift
//
//
//  Created by Greg Bolsinga on 9/22/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let atlasCache = Logger(category: "atlasCache")
}

private let expirationOffset = 60.0 * 60.0 * 24.0 * 30.0 * 6.0  // Six months
private let ExpirationStaggerDuration = 60.0 * 60.0 * 6.0  // Quarter day

/// Bump when `AtlasCache.Value` changes so that an older saved file is not read as it was.
public let atlasCacheVersion = 1

package func atlasFileName(version: Int = atlasCacheVersion) -> String {
  version == 1 ? "atlas.json" : "atlas-\(version).json"
}

public struct AtlasCache<T: AtlasGeocodable>: Sendable {
  public struct Value: Codable, Sendable {
    package var placemark: T.Place
    package let expirationDate: Date
    /// What the place was geocoded from; none in caches saved before it was kept.
    package var source: String?
  }

  private let version: Int
  private let store: any CacheCodable
  private let now: @Sendable () -> Date

  private var staggerOffset = 0.0
  private var cache: [ArchivePath: Value] = [:]

  private var fileName: String { atlasFileName(version: version) }

  public init(
    version: Int = atlasCacheVersion, store: any CacheCodable = FileManager.default,
    now: @escaping @Sendable () -> Date = { .now }
  ) {
    self.version = version
    self.store = store
    self.now = now

    do {
      let diskCache = try [ArchivePath: Value].read(fileName: fileName, store: store)
      let now = self.now()
      self.cache = diskCache.filter { $0.value.expirationDate >= now }  // Include those whose expiration date has not passed now

      if self.cache.count != diskCache.count {
        Logger.atlasCache.log("removing expired items")
        try self.save()  // Some expired, so re-write the file.
      }
    } catch {
      Logger.atlasCache.error("Cache Read Error: \(error, privacy: .public)")
      self.cache = [:]
    }
  }

  package func entry(_ id: ArchivePath) -> Value? { cache[id] }

  package mutating func add(_ id: ArchivePath, value: T.Place, source: String? = nil) {
    cache[id] = Value(
      placemark: value, expirationDate: now() + expirationOffset + staggerOffset, source: source)

    // This allows batch geocodes to be "staggered" in their expiration so they do not run all the time once the day comes.
    staggerOffset += ExpirationStaggerDuration

    do {
      try save()
    } catch {
      Logger.atlasCache.error("Cache Save Error: \(error, privacy: .public)")
    }
  }

  /// Saves under the current version's name and removes the files of the older versions.
  private func save() throws {
    try cache.save(fileName: fileName, store: store)
    for older in 1..<version {
      store.removeCache(fileName: atlasFileName(version: older))
    }
  }
}
