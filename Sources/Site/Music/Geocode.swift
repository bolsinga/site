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

func geocodeAddressString(_ addressString: String) async throws -> Placemark {
  guard let placemark = try await CLGeocoder().geocodeAddressString(addressString).first else {
    throw GeocodeError.noPlacemark
  }
  return Placemark(placemark: placemark)
}

#if canImport(Contacts)
  import Contacts

  func geocodePostalAddress(_ address: CNPostalAddress) async throws -> Placemark {
    guard let placemark = try await CLGeocoder().geocodePostalAddress(address).first else {
      throw GeocodeError.noPlacemark
    }
    return Placemark(placemark: placemark)
  }
#endif
