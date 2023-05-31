//
//  Placemark+Geometry.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import CoreLocation
import MapKit

extension CLPlacemark {
  var coordinate: CLLocationCoordinate2D {
    self.location?.coordinate ?? kCLLocationCoordinate2DInvalid
  }

  internal var radius: CLLocationDistance {
    guard let circularRegion = self.region as? CLCircularRegion else { return 100.0 }  // meters
    return circularRegion.radius
  }

  var coordinateRegion: MKCoordinateRegion {
    let radius = radius
    return MKCoordinateRegion(
      center: self.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
  }
}
