//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import CoreLocation
import Foundation

actor Atlas {
  private enum Constants {
    static let maxRequests = 50
    static let timeUntilReset = Duration.seconds(60)
  }

  typealias Cache = [Location: CLPlacemark]

  private var cache: Cache = [:]

  private var count = 0
  private var waitUntil: ContinuousClock.Instant = .now + Constants.timeUntilReset

  private func reset() {
    waitUntil = .now + Constants.timeUntilReset
    count = 0
  }

  private func idleAndReset() async throws {
    try await ContinuousClock().sleep(until: waitUntil)
    reset()
  }

  public func geocode(_ location: Location) async throws -> CLPlacemark {
    if let result = self[location] {
      return result
    }
    let result = try await gatedGeocode(location)
    self[location] = result
    return result
  }

  private func gatedGeocode(_ location: Location) async throws -> CLPlacemark {
    if ContinuousClock.now.duration(to: waitUntil) <= .seconds(0) {
      // wait time expired
      reset()
    } else if count != 0, count % Constants.maxRequests == 0 {
      // hit max requests
      try await idleAndReset()
    }

    var retry = false
    repeat {
      do {
        let placemark = try await location.geocode()
        count += 1
        return placemark
      } catch let error as NSError {
        if error.code == CLError.network.rawValue, error.domain == kCLErrorDomain {
          // throttling error
          try await idleAndReset()
          retry = true
        } else {
          throw error
        }
      } catch {
        throw error
      }
    } while retry
  }

  subscript(index: Location) -> CLPlacemark? {
    get {
      cache[index]
    }
    set(newValue) {
      cache[index] = newValue
    }
  }
}
