//
//  NearbyLocationModifier.swift
//  site
//
//  Created by Greg Bolsinga on 10/6/24.
//

import SwiftUI

struct NearbyLocationModifier: ViewModifier {
  @Environment(VaultModel.self) var model
  @AppStorage("nearby.filter") private var nearbyFilter = LocationFilter.default

  let filteredDataIsEmpty: Bool

  func body(content: Content) -> some View {
    content
      .overlay {
        if nearbyFilter.isNearby {
          NearbyLocationView(
            locationAuthorization: model.locationAuthorization,
            geocodingProgress: model.geocodingProgress, filteredDataIsEmpty: filteredDataIsEmpty)
        }
      }
  }
}

extension View {
  func nearbyLocation(filteredDataIsEmpty: Bool) -> some View {
    modifier(NearbyLocationModifier(filteredDataIsEmpty: filteredDataIsEmpty))
  }
}
