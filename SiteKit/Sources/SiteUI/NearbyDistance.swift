//
//  NearbyDistance.swift
//
//
//  Created by Greg Bolsinga on 10/8/23.
//

import CoreLocation

private func createDistanceValueFormatter() -> MeasurementFormatter {
  let formatter = MeasurementFormatter()
  formatter.unitOptions = .naturalScale

  let numberFormatter = NumberFormatter()
  numberFormatter.numberStyle = .none
  formatter.numberFormatter = numberFormatter

  return formatter
}

private func createDistanceThresholdFormatter() -> MeasurementFormatter {
  let formatter = MeasurementFormatter()
  formatter.unitOptions = .naturalScale
  formatter.unitStyle = .medium
  return formatter
}

@MainActor let nearbyDistanceValueFormatter = createDistanceValueFormatter()
@MainActor let nearbyDistanceThresholdFormatter = createDistanceThresholdFormatter()

private let minimumDistanceInMiles = 1609.34  // 1 mile
private let maximumDistanceInMiles = 160934.4  // 100 miles

private let minimumDistanceInMetric = 1000.0  // 1 km
private let maximumDistanceInMetric = 150000.0  // 150 km

private var distanceUIIsMetric: Bool {
  Locale.autoupdatingCurrent.measurementSystem == Locale.MeasurementSystem.metric
}

var minimumNearbyDistance: CLLocationDistance {
  distanceUIIsMetric ? minimumDistanceInMetric : minimumDistanceInMiles
}

var maximumNearbyDistance: CLLocationDistance {
  distanceUIIsMetric ? maximumDistanceInMetric : maximumDistanceInMiles
}

var nearbyDistanceStep: CLLocationDistance {
  minimumNearbyDistance
}
