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
        VStack {
          ProgressView(value: geocodingProgress)
            .progressViewStyle(.circular)
            .tint(.accentColor)
            #if os(macOS)
              .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            #endif
          Text("Geocoding…")
            .font(.headline)
        }
      } else if filteredDataIsEmpty {
        ContentUnavailableView(
          String(localized: "Nothing Nearby"),
          systemImage: "location.slash.circle",
          description: Text(
            "Nothing is nearby. Disable the Location Filter or increase the nearby distance filter."
          )
        )
      }
    case .restricted:
      ContentUnavailableView(
        String(localized: "Location Disabled"),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are disabled. Disable the Location Filter.")
      )
    case .denied:
      ContentUnavailableView(
        String(localized: "Location Unavailable"),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are not available. Disable the Location Filter.")
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
