//
//  NearbyLocationView.swift
//  site
//
//  Created by Greg Bolsinga on 10/2/24.
//

import SwiftUI

private enum Authorization {
  case allowed
  case denied
}

extension LocationAuthorization {
  fileprivate var authorization: Authorization {
    switch self {
    case .allowed:
      .allowed
    case .restricted, .denied:
      .denied
    }
  }
}

struct NearbyLocationView: View {
  internal init(locationAuthorization: LocationAuthorization, filteredDataIsEmpty: Bool) {
    self.authorization = locationAuthorization.authorization
    self.filteredDataIsEmpty = filteredDataIsEmpty
  }

  private let authorization: Authorization
  let filteredDataIsEmpty: Bool

  var body: some View {
    switch authorization {
    case .allowed:
      if filteredDataIsEmpty {
        ContentUnavailableView(
          String(localized: "Nothing Nearby"),
          systemImage: "location.slash.circle",
          description: Text(
            "Nothing is nearby. Disable the Location Filter or increase the nearby distance filter."
          )
        )
      }
    case .denied:
      ContentUnavailableView(
        String(localized: "Location Unavailable"),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are disabled. Enable access in Settings.")
      )
    }
  }
}

#Preview("Enabled-Geocoding-Allowed") {
  NearbyLocationView(
    locationAuthorization: .allowed, filteredDataIsEmpty: true)
}

#Preview("Enabled-Geocoding-Restricted") {
  NearbyLocationView(
    locationAuthorization: .restricted, filteredDataIsEmpty: false)
}

#Preview("Enabled-Geocoding-Denied") {
  NearbyLocationView(
    locationAuthorization: .denied, filteredDataIsEmpty: false)
}
