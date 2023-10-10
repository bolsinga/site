//
//  NearbyDistanceThresholdView.swift
//
//
//  Created by Greg Bolsinga on 10/8/23.
//

import CoreLocation
import SwiftUI

struct NearbyDistanceThresholdView: View {
  @Binding var distanceThreshold: CLLocationDistance
  @ViewBuilder var text: () -> Text

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
      Slider(
        value: $distanceThreshold, in: minimumNearbyDistance...maximumNearbyDistance,
        step: nearbyDistanceStep
      ) {
        text()
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
      Text(distanceThresholdMeasurementString)
    }
    .frame(width: 300)
    .padding([.leading, .trailing], 10)
  }
}

struct NearbyDistanceThresholdView_Previews: PreviewProvider {
  static var previews: some View {
    NearbyDistanceThresholdView(distanceThreshold: .constant(100.0)) {
      let v = "Nearby Distance"
      Text(v)
    }
  }
}
