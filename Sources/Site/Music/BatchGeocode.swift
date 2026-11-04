//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import Foundation
import Shared

struct BatchGeocode<T: AtlasGeocodable>: AsyncSequence {

  typealias Element = (ArchivePath, T, T.Place?)

  let atlas: Atlas<T>
  private let geocodables: [(ArchivePath, T)]

  /// Create a BatchGeocode.
  /// - Parameters:
  ///   - atlas: The Atlas containing the cache for the geocoding.
  ///   - geocodables: What will be geocoded, each with its ID.
  init(atlas: Atlas<T>, geocodables: [(ArchivePath, T)]) {
    self.atlas = atlas
    self.geocodables = geocodables
  }

  struct AsyncIterator: AsyncIteratorProtocol {
    let atlas: Atlas<T>
    let geocodables: [(ArchivePath, T)]

    var index: Int = 0

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < geocodables.count else { return nil }

      let (id, geocodable) = geocodables[index]
      let place = try await atlas.geocode(geocodable, id: id)
      index += 1
      return (id, geocodable, place)
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, geocodables: geocodables)
  }
}

extension BatchGeocode where T == Venue {
  /// Geocodes every venue in the vault.
  init(atlas: Atlas<Venue>, vault: Vault) {
    self.init(atlas: atlas, geocodables: vault.venueIDs())
  }
}
