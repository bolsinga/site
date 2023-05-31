//
//  Locatable.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import CoreLocation
import MapKit

protocol Locatable: Identifiable {
  var center: CLLocationCoordinate2D { get }
  var radius: CLLocationDistance { get }
}

extension Locatable {
  var region: MKCoordinateRegion {
    let radius = radius
    return MKCoordinateRegion(
      center: self.center, latitudinalMeters: radius, longitudinalMeters: radius)
  }
}
