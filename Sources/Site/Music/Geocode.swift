//
//  Geocode.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation

private enum GeocodeError: Error {
  case noPlacemark
}

extension String: Geocodable {
  func geocode() async throws -> Placemark {
    guard let placemark = try await CLGeocoder().geocodeAddressString(self).first else {
      throw GeocodeError.noPlacemark
    }
    return Placemark(placemark: placemark)
  }
}

#if canImport(Contacts)
  import Contacts

  extension CNPostalAddress: Geocodable {
    func geocode() async throws -> Placemark {
      guard let placemark = try await CLGeocoder().geocodePostalAddress(self).first else {
        throw GeocodeError.noPlacemark
      }
      return Placemark(placemark: placemark)
    }
  }
#endif
