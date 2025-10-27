//
//  Locatable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/26/25.
//

import CoreLocation

protocol Locatable {
  func nearby(to otherLocation: CLLocation, distanceThreshold: CLLocationDistance) -> Bool
}
