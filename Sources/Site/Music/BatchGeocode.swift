//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import Foundation

struct BatchGeocode<T: AtlasGeocodable>: AsyncSequence {
  typealias Element = (T, T.Place)

  let atlas: Atlas<T>
  let geocodables: [T]

  struct AsyncIterator: AsyncIteratorProtocol {
    let atlas: Atlas<T>
    let geocodables: [T]

    var index: Int = 0

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < geocodables.count else { return nil }

      let geocodable = geocodables[index]
      let placemark = try await atlas.geocode(geocodable)
      index += 1
      return (geocodable, placemark)
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, geocodables: geocodables)
  }
}
