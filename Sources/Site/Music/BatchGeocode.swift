//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import Foundation
import MapKit

struct BatchGeocode: AsyncSequence {
  typealias Element = (Venue, MKMapItem?)

  let atlas: Atlas<Venue>
  let geocodables: [Venue]

  struct AsyncIterator: AsyncIteratorProtocol {
    let atlas: Atlas<Venue>
    let geocodables: [Venue]

    var index: Int = 0

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < geocodables.count else { return nil }

      let geocodable = geocodables[index]
      let mapItem = try await atlas.geocode(geocodable)
      index += 1
      return (geocodable, mapItem)
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, geocodables: geocodables)
  }
}
