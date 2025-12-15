//
//  Geocode.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import MapKit

private enum GeocodeError: Error {
  case noPlacemark
  case noRequest
}

extension String: Geocodable {
  func geocode() async throws -> Placemark {
    guard let request = MKGeocodingRequest(addressString: self) else {
      throw GeocodeError.noRequest
    }
    guard let item = try await request.mapItems.first else {
      throw GeocodeError.noPlacemark
    }
    return Placemark.coordinate(item.location)
  }
}
