//
//  NearbyDistanceThresholdModifier.swift
//
//
//  Created by Greg Bolsinga on 10/3/23.
//

import CoreLocation
import SwiftUI

struct NearbyDistanceThresholdModifier: ViewModifier {
  let model: NearbyModel

  func body(content: Content) -> some View {
    content
      #if !os(tvOS)
        .toolbar { NearbyDistanceThresholdToolbarContent(model: model) }
      #endif
  }
}

extension View {
  func nearbyDistanceThreshold(_ model: NearbyModel) -> some View {
    modifier(NearbyDistanceThresholdModifier(model: model))
  }
}
