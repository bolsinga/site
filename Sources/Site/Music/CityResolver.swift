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
    let mapItems = try await request.mapItems
    return mapItems.lazy.compactMap { $0.addressRepresentations?.cityName }.first
  }
}

/// When to ask the geocoder again; reverse geocoding is rate limited.
struct ReverseGeocodePolicy {
  static let minimumDistance: CLLocationDistance = 1000
  static let minimumInterval: TimeInterval = 60

  struct Attempt {
    let location: CLLocation
    let date: Date
  }

  static func shouldGeocode(last: Attempt?, location: CLLocation, now: Date) -> Bool {
    guard let last else { return true }
    return location.distance(from: last.location) > minimumDistance
      && now.timeIntervalSince(last.date) >= minimumInterval
  }
}
