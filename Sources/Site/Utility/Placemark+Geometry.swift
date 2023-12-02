//
//  Placemark+Geometry.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import CoreLocation

extension CLPlacemark {
  var center: CLLocationCoordinate2D {
    self.location?.coordinate ?? kCLLocationCoordinate2DInvalid
  }

  var radius: CLLocationDistance {
    guard let circularRegion = self.region as? CLCircularRegion else { return 100.0 }  // meters
    return circularRegion.radius
  }

  func distance(from otherLocation: CLLocation) -> CLLocationDistance {
    guard let location else { return CLLocationDistanceMax }
    return location.distance(from: otherLocation)
  }

  func nearby(to otherLocation: CLLocation, distanceThreshold: CLLocationDistance) -> Bool {
    return distance(from: otherLocation) <= distanceThreshold
  }
}
