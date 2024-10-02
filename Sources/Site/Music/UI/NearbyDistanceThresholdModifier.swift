//
//  NearbyDistanceThresholdModifier.swift
//
//
//  Created by Greg Bolsinga on 10/3/23.
//

import CoreLocation
import SwiftUI

struct NearbyDistanceThresholdModifier: ViewModifier {
  @SceneStorage("nearby.distance") private var nearbyDistanceThreshold: CLLocationDistance =
    16093.44  // 10 miles

  let model: NearbyModel

  func body(content: Content) -> some View {
    content
      #if !os(tvOS)
        .toolbar { NearbyDistanceThresholdToolbarContent(model: model) }
      #endif
      .task {
        model.distanceThreshold = nearbyDistanceThreshold
      }
      .onChange(of: model.distanceThreshold) { _, newValue in
        nearbyDistanceThreshold = newValue
      }
  }
}

extension View {
  func nearbyDistanceThreshold(_ model: NearbyModel) -> some View {
    modifier(NearbyDistanceThresholdModifier(model: model))
  }
}
