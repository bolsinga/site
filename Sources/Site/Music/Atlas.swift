//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

@preconcurrency import CoreLocation
import Foundation
import os

extension Logger {
  static let atlas = Logger(category: "atlas")
}

protocol Geocodable {
  func geocode() async throws -> CLPlacemark
}

protocol AtlasGeocodable: Geocodable, Codable, Equatable, Hashable {}

private enum Constants {
  static let maxRequests = 50
  static let timeUntilReset = Duration.seconds(60)
}

private let ExpirationStaggerDuration = 60.0 * 60.0 * 6.0  // Quarter day
private var ExpirationStagger = 0.0

actor Atlas<T: AtlasGeocodable> {
  private var cache = AtlasCache<T> {
    let result = ExpirationStagger
    ExpirationStagger += ExpirationStaggerDuration
    return result
  }

  private var count = 0
  private var waitUntil: ContinuousClock.Instant = .now + Constants.timeUntilReset

  private func reset() {
    Logger.atlas.log("reset")
    waitUntil = .now + Constants.timeUntilReset
    count = 0
  }

  private func idleAndReset() async throws {
    Logger.atlas.log("idleAndReset")
    try await ContinuousClock().sleep(until: waitUntil)
    reset()
  }

  public func geocode(_ geocodable: T) async throws -> CLPlacemark {
    if let result = self[geocodable] {
      Logger.atlas.log("cached result")
      return result
    }

    let result = try await gatedGeocode(geocodable)
    self[geocodable] = result
    return result
  }

  private func gatedGeocode(_ geocodable: T) async throws -> CLPlacemark {
    Logger.atlas.log("start gatedGeocode")
    defer {
      Logger.atlas.log("end gatedGeocode")
    }

    if ContinuousClock.now.duration(to: waitUntil) <= .seconds(0) {
      // wait time expired
      Logger.atlas.log("wait expired")
      reset()
    } else if count != 0, count % Constants.maxRequests == 0 {
      // hit max requests
      Logger.atlas.log("reached max requests")
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
          Logger.atlas.log("throttle: \(error.localizedDescription, privacy: .public)")
          // throttling error
          try await idleAndReset()
          retry = true
        } else {
          Logger.atlas.error("error: \(error.localizedDescription, privacy: .public)")
          throw error
        }
      } catch {
        throw error
      }
    } while retry
  }

  subscript(index: T) -> CLPlacemark? {
    get {
      cache[index]
    }
    set(newValue) {
      cache[index] = newValue
    }
  }
}
