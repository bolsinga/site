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
  private var model: VaultModel

  internal init(
    distanceThreshold: CLLocationDistance = 0, locationFilter: LocationFilter = .none,
    vaultModel: VaultModel
  ) {
    self.distanceThreshold = distanceThreshold
    self.locationFilter = locationFilter
    self.model = vaultModel
  }

  internal var locationAuthorization: LocationAuthorization { model.locationAuthorization }
  internal var geocodingProgress: Double { model.geocodingProgress }
}
