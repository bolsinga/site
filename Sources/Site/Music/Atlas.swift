//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let atlas = Logger(category: "atlas")
}

protocol Geocodable {
  associatedtype Place
  func geocode() async throws -> Place
}

protocol AtlasGeocodable: Geocodable, Identifiable, Sendable
where ID: Codable, Place: Codable & Sendable {}

private enum Constants {
  static let maxRequests = 50
  static let timeUntilReset = Duration.seconds(60)
}

actor Atlas<T: AtlasGeocodable> {
  private var cache: AtlasCache<T>?

  private var count: Int
  private var waitUntil: ContinuousClock.Instant

  internal init(cache: AtlasCache<T>? = AtlasCache<T>()) {
    self.cache = cache
    self.count = 0
    self.waitUntil = .now + Constants.timeUntilReset
  }

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

  public func geocode(_ geocodable: T) async throws -> T.Place? {
    if let result = cache?.get(geocodable) {
      Logger.atlas.log("cached result")
      return result
    }

    guard let result = try await gatedGeocode(geocodable) else { return nil }
    cache?.add(geocodable, value: result)
    return result
  }

  private func gatedGeocode(_ geocodable: T) async throws -> T.Place? {
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
        if error.isGeocodingThrottledError {
          Logger.atlas.log("throttle: \(error.localizedDescription, privacy: .public)")
          // throttling error
          try await idleAndReset()
          retry = true
        } else if error.isGeocodingFailureError {
          Logger.atlas.error(
            "geocoding error: \(error.localizedDescription, privacy: .public) geocodable: \(String(describing: geocodable))"
          )
          return nil
        } else {
          Logger.atlas.error(
            "unknown error: \(error.localizedDescription, privacy: .public) geocodable: \(String(describing: geocodable))"
          )
          throw error
        }
      } catch {
        throw error
      }
    } while retry
  }
}
