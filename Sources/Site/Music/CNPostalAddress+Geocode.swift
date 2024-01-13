//
//  CNPostalAddress+Geocode.swift
//
//
//  Created by Greg Bolsinga on 12/4/23.
//

import CoreLocation

#if canImport(Contacts)
  import Contacts

  extension CNPostalAddress: Geocodable {
    func geocode() async throws -> CLPlacemark {
      guard let placemark = try await CLGeocoder().geocodePostalAddress(self).first else {
        throw GeocodeError.noPlacemark
      }
      return placemark
    }
  }
#endif
