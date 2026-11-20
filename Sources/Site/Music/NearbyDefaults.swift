//
//  NearbyDefaults.swift
//
//
//  Created by Greg Bolsinga on 11/28/23.
//

import CoreLocation
import Foundation
import SwiftUI

let defaultNearbyDistanceThreshold: CLLocationDistance = 16093.44  // 10 miles

/// The nearby distance the person chose, kept per app.
@propertyWrapper
struct NearbyDistanceStorage: DynamicProperty {
  @AppStorage("nearby.distance") private var distance = defaultNearbyDistanceThreshold

  var wrappedValue: CLLocationDistance {
    get { distance }
    nonmutating set { distance = newValue }
  }

  var projectedValue: Binding<CLLocationDistance> { $distance }
}
