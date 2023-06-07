//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import CoreLocation
import Foundation

struct BatchGeocode: AsyncSequence {
  typealias Element = (Location, CLPlacemark)

  let atlas: Atlas
  let locations: [Location]

  struct AsyncIterator: AsyncIteratorProtocol {
    let atlas: Atlas
    let locations: [Location]

    var index: Int = 0

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < locations.count else { return nil }

      let location = locations[index]
      let placemark = try await atlas.geocode(location)
      index += 1
      return (location, placemark)
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, locations: locations)
  }
}
