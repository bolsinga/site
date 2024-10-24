//
//  NearbyDistanceThresholdView.swift
//
//
//  Created by Greg Bolsinga on 10/8/23.
//

import CoreLocation
import SwiftUI

@MainActor
struct NearbyDistanceThresholdView: View {
  @Binding var distanceThreshold: CLLocationDistance

  private var distanceThresholdMeasurementString: String {
    nearbyDistanceThresholdFormatter.string(
      from: Measurement(value: distanceThreshold, unit: UnitLength.meters))
  }

  private func distanceValueString(_ distance: CLLocationDistance) -> String {
    nearbyDistanceValueFormatter.string(
      from: Measurement(value: distance, unit: UnitLength.meters))
  }

  var body: some View {
    VStack {
      #if !os(tvOS)
        Slider(
          value: $distanceThreshold, in: minimumNearbyDistance...maximumNearbyDistance,
          step: nearbyDistanceStep
        ) {
        } minimumValueLabel: {
          Label {
            Text(distanceValueString(minimumNearbyDistance))
          } icon: {
            Image(systemName: "minus.circle")
          }
        } maximumValueLabel: {
          Label {
            Text(distanceValueString(maximumNearbyDistance))
          } icon: {
            Image(systemName: "plus.circle")
          }
        }
      #endif
      Text(distanceThresholdMeasurementString)
    }
  }
}

#Preview {
  NearbyDistanceThresholdView(distanceThreshold: .constant(100.0))
}
