//
//  Placemark+Geometry.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import CoreLocation
import MapKit

extension CLPlacemark: Locatable {
  var center: CLLocationCoordinate2D {
    self.location?.coordinate ?? kCLLocationCoordinate2DInvalid
  }

  var radius: CLLocationDistance {
    guard let circularRegion = self.region as? CLCircularRegion else { return 100.0 }  // meters
    return circularRegion.radius
  }
}
