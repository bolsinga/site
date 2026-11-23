//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import Foundation
import Shared

public struct BatchGeocode<T: AtlasGeocodable>: AsyncSequence {

  public typealias Element = (ArchivePath, T, T.Place?)

  public let atlas: Atlas<T>
  private let geocodables: [(ArchivePath, T)]

  /// Create a BatchGeocode.
  /// - Parameters:
  ///   - atlas: The Atlas containing the cache for the geocoding.
  ///   - geocodables: What will be geocoded, each with its ID.
  public init(atlas: Atlas<T>, geocodables: [(ArchivePath, T)]) {
    self.atlas = atlas
    self.geocodables = geocodables
  }

  /// Cached places come first, so they show at once. Then those never geocoded, then those
  /// whose cached place is stale, which come again with their new place.
  public struct AsyncIterator: AsyncIteratorProtocol {
    public let atlas: Atlas<T>
    public let geocodables: [(ArchivePath, T)]

    public var index: Int = 0
    private var uncached: [(ArchivePath, T)] = []
    private var uncachedIndex = 0
    private var stale: [(ArchivePath, T)] = []
    private var staleIndex = 0

    public init(atlas: Atlas<T>, geocodables: [(ArchivePath, T)]) {
      self.atlas = atlas
      self.geocodables = geocodables
    }

    public mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      while index < geocodables.count {
        let (id, geocodable) = geocodables[index]
        index += 1
        guard let cached = await atlas.cached(geocodable, id: id) else {
          uncached.append((id, geocodable))
          continue
        }
        if !cached.isCurrent { stale.append((id, geocodable)) }
        return (id, geocodable, cached.place)
      }

      if uncachedIndex < uncached.count {
        let (id, geocodable) = uncached[uncachedIndex]
        uncachedIndex += 1
        return (id, geocodable, try await atlas.geocode(geocodable, id: id))
      }

      while staleIndex < stale.count {
        let (id, geocodable) = stale[staleIndex]
        staleIndex += 1
        // When it can't be found again, the stale place stays, and a later batch tries again.
        guard let place = try await atlas.geocode(geocodable, id: id) else { continue }
        return (id, geocodable, place)
      }
      return nil
    }
  }

  public func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, geocodables: geocodables)
  }
}

extension BatchGeocode where T == Venue {
  /// Geocodes every venue in the vault.
  public init(atlas: Atlas<Venue>, vault: Vault) {
    self.init(atlas: atlas, geocodables: vault.venueIDs())
  }
}
