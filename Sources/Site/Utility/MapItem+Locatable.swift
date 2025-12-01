//
//  MapItem+Locatable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/30/25.
//

import MapKit

extension MKMapItem: Locatable {
  func nearby(to otherLocation: CLLocation, distanceThreshold: CLLocationDistance) -> Bool {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      return location.nearby(to: otherLocation, distanceThreshold: distanceThreshold)
    } else {
      guard let location = placemark.location else { return false }
      return location.nearby(to: otherLocation, distanceThreshold: distanceThreshold)
    }
  }
}
