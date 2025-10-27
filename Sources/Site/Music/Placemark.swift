//
//  Placemark.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation

struct Placemark: Codable, Sendable {
  @NSCodingCodable
  var placemark: CLPlacemark
}

extension Placemark: Locatable {
  func nearby(to otherLocation: CLLocation, distanceThreshold: CLLocationDistance) -> Bool {
    placemark.nearby(to: otherLocation, distanceThreshold: distanceThreshold)
  }
}
