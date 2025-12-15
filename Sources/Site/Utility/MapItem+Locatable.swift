//
//  MapItem+Locatable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/30/25.
//

import MapKit

extension MKMapItem: Locatable {
  func nearby(to otherLocation: CLLocation, distanceThreshold: CLLocationDistance) -> Bool {
    location.nearby(to: otherLocation, distanceThreshold: distanceThreshold)
  }
}
