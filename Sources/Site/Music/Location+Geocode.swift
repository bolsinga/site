//
//  Location+Geocode.swift
//
//
//  Created by Greg Bolsinga on 2/27/23.
//

import Contacts
import Foundation
import MapKit

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

  func geocode() async throws -> MKMapItem {
    MKMapItem(placemark: MKPlacemark(placemark: try await geocode()))
  }
}

extension Location {
  public func geocode() async throws -> CLPlacemark {
    try await postalAddress.geocode()
  }

  public func geocode() async throws -> MKMapItem {
    try await postalAddress.geocode()
  }
}
