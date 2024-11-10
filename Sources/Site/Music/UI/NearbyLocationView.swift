//
//  NearbyLocationView.swift
//  site
//
//  Created by Greg Bolsinga on 10/2/24.
//

import SwiftUI

struct NearbyLocationView: View {
  let locationAuthorization: LocationAuthorization
  let geocodingProgress: Double
  let filteredDataIsEmpty: Bool

  var body: some View {
    switch locationAuthorization {
    case .allowed:
      if geocodingProgress < 1.0 {
        ProgressView(value: geocodingProgress)
          .progressViewStyle(.circular)
          .tint(.accentColor)
          #if os(macOS)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
          #endif
      } else if filteredDataIsEmpty {
        ContentUnavailableView(
          String(localized: "Nothing Nearby", bundle: .module),
          systemImage: "location.slash.circle",
          description: Text(
            "Nothing is nearby. Disable the Location Filter or increase the nearby distance filter.",
            bundle: .module)
        )
      }
    case .restricted:
      ContentUnavailableView(
        String(localized: "Location Disabled", bundle: .module),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are disabled. Disable the Location Filter.", bundle: .module)
      )
    case .denied:
      ContentUnavailableView(
        String(localized: "Location Unavailable", bundle: .module),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are not available. Disable the Location Filter.", bundle: .module)
      )
    }
  }
}

#Preview("Enabled-Geocoding-Allowed") {
  NearbyLocationView(
    locationAuthorization: .allowed, geocodingProgress: 0, filteredDataIsEmpty: true)
}

#Preview("Enabled-Geocoding-Allowed-Empty") {
  NearbyLocationView(
    locationAuthorization: .allowed, geocodingProgress: 1, filteredDataIsEmpty: true)
}

#Preview("Enabled-Geocoding-Restricted") {
  NearbyLocationView(
    locationAuthorization: .restricted, geocodingProgress: 0, filteredDataIsEmpty: false)
}

#Preview("Enabled-Geocoding-Denied") {
  NearbyLocationView(
    locationAuthorization: .denied, geocodingProgress: 1, filteredDataIsEmpty: false)
}
