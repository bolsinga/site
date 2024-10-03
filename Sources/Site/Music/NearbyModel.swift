//
//  NearbyModel.swift
//
//
//  Created by Greg Bolsinga on 11/28/23.
//

import CoreLocation
import Foundation

@Observable final class NearbyModel {
  internal var distanceThreshold: CLLocationDistance
  internal var locationFilter: LocationFilter

  internal init(distanceThreshold: CLLocationDistance = 0, locationFilter: LocationFilter = .none) {
    self.distanceThreshold = distanceThreshold
    self.locationFilter = locationFilter
  }
}
