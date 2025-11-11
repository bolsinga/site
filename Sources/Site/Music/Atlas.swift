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

  private let throttle = Throttle<T.Place>(
    batchSize: Constants.maxRequests, timeUntilReset: Constants.timeUntilReset)

  internal init(cache: AtlasCache<T>? = AtlasCache<T>()) {
    self.cache = cache
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
    Logger.atlas.log("gatedGeocode")

    return try await throttle.perform {
      do {
        return Throttle.Control.success(try await geocodable.geocode())
      } catch let error as NSError {
        if error.isGeocodingThrottledError {
          Logger.atlas.log("throttle: \(error.localizedDescription, privacy: .public)")
          // throttling error, try again
          return Throttle.Control.pauseEntry
        } else if error.isGeocodingFailureError {
          Logger.atlas.error(
            "geocoding error: \(error.localizedDescription, privacy: .public) geocodable: \(String(describing: geocodable))"
          )
          return Throttle.Control.nonRecoverableError
        } else {
          Logger.atlas.error(
            "unknown error: \(error.localizedDescription, privacy: .public) geocodable: \(String(describing: geocodable))"
          )
          throw error
        }
      } catch {
        throw error
      }
    }
  }
}
