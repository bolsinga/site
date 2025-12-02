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
  case noRequest
}

extension String: Geocodable {
  func geocode() async throws -> Placemark {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      guard let request = MKGeocodingRequest(addressString: self) else {
        throw GeocodeError.noRequest
      }
      guard let item = try await request.mapItems.first else {
        throw GeocodeError.noPlacemark
      }
      return Placemark.coordinate(item.location)
    } else {
      guard let placemark = try await CLGeocoder().geocodeAddressString(self).first,
        let location = placemark.location
      else {
        throw GeocodeError.noPlacemark
      }
      return Placemark.coordinate(location)
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
        return Placemark.coordinate(location)
      }
    }
  }
#endif
