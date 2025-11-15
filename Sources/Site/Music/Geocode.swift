//
//  Geocode.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation
import MapKit

private enum GeocodeError: Error {
  case invalidOS
  case noPlacemark
}

extension String: Geocodable {
  func geocode() async throws -> Placemark {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      guard let item = try await MKGeocodingRequest(addressString: self)?.mapItems.first else {
        throw GeocodeError.noPlacemark
      }
      return Placemark(location: item.location)
    } else {
      guard let placemark = try await CLGeocoder().geocodeAddressString(self).first,
        let location = placemark.location
      else {
        throw GeocodeError.noPlacemark
      }
      return Placemark(location: location)
    }
  }
}

#if canImport(Contacts)
  import Contacts

  extension CNPostalAddress: Geocodable {
    func geocode() async throws -> Placemark {
      if #available(iOS 26, macOS 26, tvOS 26, *) {
        throw GeocodeError.invalidOS
      } else {
        guard let placemark = try await CLGeocoder().geocodePostalAddress(self).first,
          let location = placemark.location
        else {
          throw GeocodeError.noPlacemark
        }
        return Placemark(location: location)
      }
    }
  }
#endif
