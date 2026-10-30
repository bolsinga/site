//
//  NearbyLocationView.swift
//  site
//
//  Created by Greg Bolsinga on 10/2/24.
//

import MapKit
import Shared
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

/// Puts the content on a material card, so it stays legible over a map.
struct MapCardModifier: ViewModifier {
  let enabled: Bool

  func body(content: Content) -> some View {
    if enabled {
      content
        // ContentUnavailableView fills what it is given; this shrinks the card to its text.
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
        .padding(.horizontal, 16)
    } else {
      content
    }
  }
}

struct NearbyLocationView: View {
  internal init(
    locationAuthorization: LocationAuthorization, filteredDataIsEmpty: Bool,
    overMap: Bool = false
  ) {
    self.authorization = locationAuthorization.authorization
    self.filteredDataIsEmpty = filteredDataIsEmpty
    self.overMap = overMap
  }

  private let authorization: Authorization
  let filteredDataIsEmpty: Bool

  /// Shown over a map, instead of an empty background.
  let overMap: Bool

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
        .modifier(MapCardModifier(enabled: overMap))
      }
    case .denied:
      ContentUnavailableView(
        String(localized: "Location Unavailable"),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are disabled. Enable access in Settings.")
      )
      .modifier(MapCardModifier(enabled: overMap))
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

#Preview("Denied-Over-Map") {
  ZStack {
    Map()
    NearbyLocationView(
      locationAuthorization: .denied, filteredDataIsEmpty: false, overMap: true)
  }
}
