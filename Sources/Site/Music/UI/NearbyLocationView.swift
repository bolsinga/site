//
//  NearbyLocationView.swift
//  site
//
//  Created by Greg Bolsinga on 10/2/24.
//

import SwiftUI

struct NearbyLocationView: View {
  let model: NearbyModel
  let filteredDataIsEmpty: Bool

  var body: some View {
    switch model.locationAuthorization {
    case .allowed:
      if model.geocodingProgress < 1.0 {
        ProgressView(value: model.geocodingProgress)
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
        description: Text("Location Services are disabled.", bundle: .module)
      )
      .frame(height: 200)
    case .denied:
      ContentUnavailableView(
        String(localized: "Location Unavailable", bundle: .module),
        systemImage: "location.slash.circle",
        description: Text("Location Services are not available.", bundle: .module)
      )
      .frame(height: 200)
    }
  }
}

#Preview("Enabled-Geocoding-Allowed") {
  NearbyLocationView(
    model: NearbyModel(
      locationFilter: .nearby,
      vaultModel: VaultModel(
        vaultPreviewData, executeAsynchronousTasks: false, fakeLocationAuthorization: .allowed,
        fakeGeocodingProgress: 0)), filteredDataIsEmpty: true)
}

#Preview("Enabled-Geocoding-Allowed-Empty") {
  NearbyLocationView(
    model: NearbyModel(
      locationFilter: .nearby,
      vaultModel: VaultModel(
        vaultPreviewData, executeAsynchronousTasks: false, fakeLocationAuthorization: .allowed,
        fakeGeocodingProgress: 1)), filteredDataIsEmpty: true)
}

#Preview("Enabled-Geocoding-Restricted") {
  NearbyLocationView(
    model: NearbyModel(
      locationFilter: .nearby,
      vaultModel: VaultModel(
        vaultPreviewData, executeAsynchronousTasks: false, fakeLocationAuthorization: .restricted,
        fakeGeocodingProgress: 0)), filteredDataIsEmpty: false)
}

#Preview("Enabled-Geocoding-Denied") {
  NearbyLocationView(
    model: NearbyModel(
      locationFilter: .nearby,
      vaultModel: VaultModel(
        vaultPreviewData, executeAsynchronousTasks: false, fakeLocationAuthorization: .denied,
        fakeGeocodingProgress: 1)), filteredDataIsEmpty: false)
}
