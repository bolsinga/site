//
//  NearbyDistanceThresholdModifier.swift
//
//
//  Created by Greg Bolsinga on 10/3/23.
//

import CoreLocation
import SwiftUI

struct NearbyDistanceThresholdModifier: ViewModifier {
  @Binding var distanceThreshold: CLLocationDistance
  @State private var presentDistanceSliderPopover = false

  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          let labelText = Text("Nearby Distance", bundle: .module)
          Button {
            presentDistanceSliderPopover = true
          } label: {
            Label {
              labelText
            } icon: {
              Image(systemName: "gear")
            }
          }
          .popover(isPresented: $presentDistanceSliderPopover) {
            NearbyDistanceThresholdView(distanceThreshold: $distanceThreshold) { labelText }
              .presentationCompactAdaptation(.popover)
          }
        }
      }
  }
}

extension View {
  func nearbyDistanceThreshold(_ distanceThreshold: Binding<CLLocationDistance>) -> some View {
    modifier(NearbyDistanceThresholdModifier(distanceThreshold: distanceThreshold))
  }
}
