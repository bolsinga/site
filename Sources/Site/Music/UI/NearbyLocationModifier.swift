//
//  NearbyLocationModifier.swift
//  site
//
//  Created by Greg Bolsinga on 10/6/24.
//

import SwiftUI

struct NearbyLocationModifier: ViewModifier {
  let locationFilter: LocationFilter
  let locationAuthorization: LocationAuthorization
  let geocodingProgress: Double
  let filteredDataIsEmpty: Bool

  func body(content: Content) -> some View {
    content
      .overlay {
        if locationFilter.isNearby {
          NearbyLocationView(
            locationAuthorization: locationAuthorization, geocodingProgress: geocodingProgress,
            filteredDataIsEmpty: filteredDataIsEmpty)
        }
      }
  }
}

extension View {
  func nearbyLocation(
    locationFilter: LocationFilter, locationAuthorization: LocationAuthorization,
    geocodingProgress: Double, filteredDataIsEmpty: Bool
  ) -> some View {
    modifier(
      NearbyLocationModifier(
        locationFilter: locationFilter, locationAuthorization: locationAuthorization,
        geocodingProgress: geocodingProgress, filteredDataIsEmpty: filteredDataIsEmpty))
  }
}
