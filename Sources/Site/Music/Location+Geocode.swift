//
//  Location+Geocode.swift
//
//
//  Created by Greg Bolsinga on 2/27/23.
//

import CoreLocation
import Foundation

#if !canImport(Contacts)
  import MapKit
#endif

extension Location: AtlasGeocodable {
  public func geocode() async throws -> CLPlacemark {
    #if canImport(Contacts)
      try await postalAddress.geocode()
    #else
      try await addressString.geocode()
    #endif
  }
}
