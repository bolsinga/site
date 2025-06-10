//
//  Venue+Geocodable.swift
//
//
//  Created by Greg Bolsinga on 9/13/23.
//

import Foundation

extension Venue: AtlasGeocodable {
  func geocode() async throws -> Placemark {
    try await location.geocode()
  }
}
