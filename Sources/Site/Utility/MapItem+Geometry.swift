//
//  MapItem+Geometry.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import MapKit

extension MKMapItem {
  var center: CLLocationCoordinate2D {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      self.location.coordinate
    } else {
      self.placemark.center
    }
  }
  var radius: CLLocationDistance {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      // FB19027378 No region for a MKMapItem
      100
    } else {
      self.placemark.radius
    }
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
