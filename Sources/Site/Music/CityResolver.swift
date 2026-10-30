//
//  CityResolver.swift
//  site
//
//  Created by Greg Bolsinga on 10/29/26.
//

import CoreLocation
import Foundation
import MapKit

protocol CityResolver: Sendable {
  func city(for location: CLLocation) async throws -> String?
}

struct MapKitCityResolver: CityResolver {
  func city(for location: CLLocation) async throws -> String? {
    guard let request = MKReverseGeocodingRequest(location: location) else { return nil }
    // cancel() is made to be called from another thread.
    nonisolated(unsafe) let pending = request
    let mapItems = try await withTaskCancellationHandler {
      try await pending.mapItems
    } onCancel: {
      pending.cancel()
    }
    return mapItems.lazy.compactMap { $0.addressRepresentations?.cityName }.first
  }
}

/// When to ask the geocoder again; reverse geocoding is rate limited.
struct ReverseGeocodePolicy {
  static let minimumDistance: CLLocationDistance = 1000
  static let minimumInterval: TimeInterval = 60
  /// A move this far is a new place, so it geocodes without waiting out the interval.
  static let jumpDistance: CLLocationDistance = 50_000

  struct Attempt {
    let location: CLLocation
    let date: Date
  }

  static func shouldGeocode(last: Attempt?, location: CLLocation, now: Date) -> Bool {
    guard let last else { return true }
    let distance = location.distance(from: last.location)
    if distance > jumpDistance { return true }
    return distance > minimumDistance && now.timeIntervalSince(last.date) >= minimumInterval
  }
}
