//
//  Atlas+BatchGeocoding.swift
//
//
//  Created by Greg Bolsinga on 5/3/23.
//

import CoreLocation
import Foundation

extension Array {
  fileprivate func batched(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}

private enum Constants {
  static let maxRequests = 50
  static let timeUntilReset = 60
}

private enum ThrottleError: Error {
  case throttled
}

extension NSError {
  fileprivate func throwIfThrottled() throws {
    guard self.code == CLError.network.rawValue, self.domain == kCLErrorDomain else { return }
    throw ThrottleError.throttled
  }
}

extension Atlas {
  public func geocode(batch locations: [Location]) async {
    let uncachedLocations = locations.filter { cache[$0] == nil }

    do {
      let batchesOfLocations = uncachedLocations.batched(into: Constants.maxRequests)
      let lastBatchOfLocations = batchesOfLocations.last

      for batchedLocations in batchesOfLocations {
        let clock = ContinuousClock()
        let until = clock.now + .seconds(Constants.timeUntilReset)

        for location in batchedLocations {
          do {
            let _ = try await geocode(location)
          } catch let error as NSError {
            try error.throwIfThrottled()
          }
        }

        if batchedLocations != lastBatchOfLocations {
          // end of batch, wait for throttle
          do {
            try await Task.sleep(until: until, clock: clock)
          } catch {}
        }
      }
    } catch ThrottleError.throttled {
      // wait for throttle
      do {
        try await Task.sleep(until: .now + .seconds(Constants.timeUntilReset), clock: .continuous)
      } catch {}

      // start over
      await geocode(batch: uncachedLocations)
    } catch {
      print("Unknown Batch Geocoding Error: \(error)")
    }
    print("Batch Geocoding Completed.")
  }
}
