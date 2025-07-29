//
//  NearbyLocationModifier.swift
//  site
//
//  Created by Greg Bolsinga on 10/6/24.
//

import SwiftUI

struct NearbyLocationModifier: ViewModifier {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel

  let filteredDataIsEmpty: Bool

  func body(content: Content) -> some View {
    content
      .overlay {
        if nearbyModel.locationFilter.isNearby {
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
