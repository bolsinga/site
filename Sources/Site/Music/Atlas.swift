//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import CoreLocation
import Foundation
import os

extension Logger {
  fileprivate static let atlas = Logger(category: "atlas")
}

enum GeocodeError: Error {
  case noPlacemark
}

protocol Geocodable {
  func geocode() async throws -> CLPlacemark
}

protocol AtlasGeocodable: Geocodable, Codable, Equatable, Hashable, Sendable {}

private enum Constants {
  static let maxRequests = 50
  static let timeUntilReset = Duration.seconds(60)
}

actor Atlas<T: AtlasGeocodable> {
  private var cache = AtlasCache<T>()

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
    if let result = await cache.get(geocodable) {
      Logger.atlas.log("cached result")
      return result
    }

    let result = try await gatedGeocode(geocodable)
    await cache.add(geocodable, value: result)
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
}
