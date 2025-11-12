//
//  Location+Locatable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/12/25.
//

import CoreLocation

extension CLLocation: Locatable {
  func nearby(to otherLocation: CLLocation, distanceThreshold: CLLocationDistance) -> Bool {
    distance(from: otherLocation) <= distanceThreshold
  }
}
