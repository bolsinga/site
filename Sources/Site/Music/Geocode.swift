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
    guard let placemark = try await CLGeocoder().geocodeAddressString(self).first,
      let location = placemark.location
    else {
      throw GeocodeError.noPlacemark
    }
    return Placemark(location: location)
  }
}

#if canImport(Contacts)
  import Contacts

  extension CNPostalAddress: Geocodable {
    func geocode() async throws -> Placemark {
      guard let placemark = try await CLGeocoder().geocodePostalAddress(self).first,
        let location = placemark.location
      else {
        throw GeocodeError.noPlacemark
      }
      return Placemark(location: location)
    }
  }
#endif
