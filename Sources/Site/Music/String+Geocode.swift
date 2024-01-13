//
//  String+Geocode.swift
//
//
//  Created by Greg Bolsinga on 12/4/23.
//

import CoreLocation

extension String: Geocodable {
  func geocode() async throws -> CLPlacemark {
    guard let placemark = try await CLGeocoder().geocodeAddressString(self).first else {
      throw GeocodeError.noPlacemark
    }
    return placemark
  }
}
