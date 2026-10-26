//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import Foundation
import MapKit
import Shared

struct BatchGeocode: AsyncSequence {

  typealias Element = (ArchivePath, MKMapItem?)

  let atlas: Atlas<Venue>
  private let geocodables: [(ArchivePath, Venue)]

  /// Create a BatchGeocode.
  /// - Parameters:
  ///   - atlas: The Atlas containing the cache for the geocoding.
  ///   - vault: This is used to find what items will be geocoded, as well as defining ID
  init(atlas: Atlas<Venue>, vault: Vault) {
    self.atlas = atlas
    self.geocodables = vault.venueIDs().map { ($0.0, $0.1) }
  }

  struct AsyncIterator: AsyncIteratorProtocol {
    let atlas: Atlas<Venue>
    let geocodables: [(ArchivePath, Venue)]

    var index: Int = 0

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < geocodables.count else { return nil }

      let (id, geocodable) = geocodables[index]
      let mapItem = try await atlas.geocode(geocodable, id: id)
      index += 1
      return (id, mapItem)
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, geocodables: geocodables)
  }
}
