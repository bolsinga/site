//
//  Placemark.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation

struct Placemark: Locatable {
  @NSCodingCodable
  var placemark: CLPlacemark

  func nearby(to otherLocation: CLLocation, distanceThreshold: CLLocationDistance) -> Bool {
    placemark.nearby(to: otherLocation, distanceThreshold: distanceThreshold)
  }
}
