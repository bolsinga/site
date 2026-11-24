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

public protocol Geocodable {
  associatedtype Place
  func geocode() async throws -> Place
}

public protocol AtlasGeocodable: Geocodable, Sendable
where Place: Codable & Sendable {
  /// Whether the place cached for this item can be used; if not, the item is geocoded again.
  func canUseCached(_ place: Place) -> Bool

  /// What the item is geocoded from, so a cached place from something else is geocoded again.
  var geocodeSource: String? { get }
}

extension AtlasGeocodable {
  public func canUseCached(_ place: Place) -> Bool { true }

  public var geocodeSource: String? { nil }
}

/// MapKit allows the app this many requests of each kind in each period.
package enum MapKitLimits {
  package static let maxRequests = 50
  package static let timeUntilReset = Duration.seconds(60)
}

public actor Atlas<T: AtlasGeocodable> {
  private var cache: AtlasCache<T>?

  private let throttle = Throttle<T.Place>(
    batchSize: MapKitLimits.maxRequests, timeUntilReset: MapKitLimits.timeUntilReset)

  public init(cache: AtlasCache<T>? = AtlasCache<T>()) {
    self.cache = cache
  }

  /// The cached place, and whether it is still current for what the item is geocoded from.
  package func cached(_ geocodable: T, id: ArchivePath) -> (place: T.Place, isCurrent: Bool)? {
    guard let entry = cache?.entry(id) else { return nil }
    let isCurrent =
      geocodable.canUseCached(entry.placemark) && entry.source == geocodable.geocodeSource
    return (entry.placemark, isCurrent)
  }

  package func geocode(_ geocodable: T, id: ArchivePath) async throws -> T.Place? {
    if let cached = cached(geocodable, id: id), cached.isCurrent {
      Logger.atlas.log("cached result")
      return cached.place
    }

    guard let result = try await gatedGeocode(geocodable) else { return nil }
    cache?.add(id, value: result, source: geocodable.geocodeSource)
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
