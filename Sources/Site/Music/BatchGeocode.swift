//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import CoreLocation
import Foundation

struct BatchGeocode<T: AtlasItem>: AsyncSequence {
  typealias Element = (T, CLPlacemark)

  let atlas: Atlas<T>
  let items: [T]

  struct AsyncIterator: AsyncIteratorProtocol {
    let atlas: Atlas<T>
    let items: [T]

    var index: Int = 0

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < items.count else { return nil }

      let item = items[index]
      let placemark = try await atlas.geocode(item)
      index += 1
      return (item, placemark)
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, items: items)
  }
}
