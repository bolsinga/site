//
//  Venue+Geocodable.swift
//
//
//  Created by Greg Bolsinga on 9/13/23.
//

import CoreLocation
import Foundation

extension Venue: AtlasGeocodable {
  func geocode() async throws -> CLPlacemark {
    try await location.geocode()
  }
}
