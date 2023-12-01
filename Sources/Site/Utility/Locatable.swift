//
//  Locatable.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

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

  var rect: MKMapRect {
    let center = center

    let mapPointOffset = MKMapPointsPerMeterAtLatitude(center.latitude) * radius / 2.0

    return MKMapRect(origin: MKMapPoint(center), size: MKMapSize(width: 1, height: 1)).insetBy(
      dx: -mapPointOffset, dy: -mapPointOffset)
  }

  var paddedRect: MKMapRect {
    let locatableRect = self.rect
    return locatableRect.insetBy(dx: -locatableRect.width / 10.0, dy: -locatableRect.height / 10.0)
  }
}
