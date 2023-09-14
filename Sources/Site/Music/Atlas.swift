//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import CoreLocation
import Foundation

protocol Geocodable {
  func geocode() async throws -> CLPlacemark
}

protocol AtlasItem: Geocodable, Identifiable {}

private enum Constants {
  static let maxRequests = 50
  static let timeUntilReset = Duration.seconds(60)
}

actor Atlas<T: AtlasItem> {
  typealias Cache = [T.ID: CLPlacemark]

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

  public func geocode(_ item: T) async throws -> CLPlacemark {
    if let result = self[item] {
      return result
    }
    let result = try await gatedGeocode(item)
    self[item] = result
    return result
  }

  private func gatedGeocode<G: Geocodable>(_ geocodable: G) async throws -> CLPlacemark {
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
        let placemark = try await geocodable.geocode()
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

  subscript(index: T) -> CLPlacemark? {
    get {
      cache[index.id]
    }
    set(newValue) {
      cache[index.id] = newValue
    }
  }
}
