//
//  NearbyModel.swift
//
//
//  Created by Greg Bolsinga on 11/28/23.
//

import CoreLocation
import Foundation

@Observable final class NearbyModel {
  var distanceThreshold: CLLocationDistance
  var locationFilter: LocationFilter
  var locationAuthorization: LocationAuthorization
  var geocodingProgress: Double

  internal init(
    distanceThreshold: CLLocationDistance = 0, locationFilter: LocationFilter = .none,
    locationAuthorization: LocationAuthorization = .allowed, geocodingProgress: Double = 0
  ) {
    self.distanceThreshold = distanceThreshold
    self.locationFilter = locationFilter
    self.locationAuthorization = locationAuthorization
    self.geocodingProgress = geocodingProgress
  }
}
