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
  @State private var presentDistanceSliderPopover = false

  func body(content: Content) -> some View {
    content
      #if !os(tvOS)
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            @Bindable var model = model
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
              NearbyDistanceThresholdView(distanceThreshold: $model.distanceThreshold) {
                labelText
              }
              .presentationCompactAdaptation(.popover)
            }
          }
        }
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
