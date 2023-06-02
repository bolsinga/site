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
    var batchStartTime: ContinuousClock.Instant = .now

    mutating func next() async throws -> Element? {
      guard !Task.isCancelled else { return nil }

      guard index < locations.count else { return nil }

      let clock = ContinuousClock.continuous

      if index != 0, index % Constants.maxRequests == 0 {
        // hit max requests, wait for throttle time.
        try await clock.sleep(until: batchStartTime + Constants.timeUntilReset)
        batchStartTime = .now
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
            // throttling error. wait for throttle time.
            try await clock.sleep(until: .now + Constants.timeUntilReset)
            batchStartTime = .now
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
