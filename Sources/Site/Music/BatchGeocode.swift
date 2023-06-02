//
//  BatchGeocode.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import CoreLocation
import Foundation

private enum Constants {
  static let maxRequests = 50
  static let timeUntilReset = Duration.seconds(60)
}

struct BatchGeocode: AsyncSequence {
  typealias Element = (Location, CLPlacemark)

  let atlas: Atlas
  let locations: [Location]

  struct AsyncIterator: AsyncIteratorProtocol {
    let atlas: Atlas
    let locations: [Location]

    var index: Int = 0
    var lastWaitingIndex: Int = 0
    var waitUntil: ContinuousClock.Instant = .now + Constants.timeUntilReset

    private mutating func idleAndReset() async throws {
      try await ContinuousClock().sleep(until: waitUntil)
      waitUntil = .now + Constants.timeUntilReset
      lastWaitingIndex = index
    }

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < locations.count else { return nil }

      let requestIndex = abs(index - lastWaitingIndex)
      if requestIndex != 0, requestIndex % Constants.maxRequests == 0 {
        // hit max requests
        try await idleAndReset()
      }

      var retry: Bool = true
      while retry {
        do {
          let location = locations[index]
          let placemark = try await atlas.geocode(location)
          index += 1
          return (location, placemark)
        } catch let error as NSError {
          if error.code == CLError.network.rawValue, error.domain == kCLErrorDomain {
            // throttling error
            try await idleAndReset()
          }
        } catch {
          retry = false
        }
      }

      return nil
    }
  }

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(atlas: atlas, locations: locations)
  }
}
