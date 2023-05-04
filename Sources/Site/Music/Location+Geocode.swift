//
//  Location+Geocode.swift
//
//
//  Created by Greg Bolsinga on 2/27/23.
//

import Contacts
import CoreLocation
import Foundation

extension CNPostalAddress {
  private enum GeocodeError: Error {
    case noPlacemark
  }

  func geocode() async throws -> CLPlacemark {
    guard let placemark = try await CLGeocoder().geocodePostalAddress(self).first else {
      throw GeocodeError.noPlacemark
    }
    return placemark
  }
}

extension Location {
  public func geocode() async throws -> CLPlacemark {
    try await postalAddress.geocode()
  }
}
