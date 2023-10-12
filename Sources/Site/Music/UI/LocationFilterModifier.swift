//
//  LocationFilterModifier.swift
//
//
//  Created by Greg Bolsinga on 10/5/23.
//

import SwiftUI

struct LocationFilterModifier: ViewModifier {
  @Binding var locationFilter: LocationFilter
  @Binding var geocodingProgress: Double
  @Binding var locationAuthorization: LocationAuthorization

  @ViewBuilder private var nearbyEnabledView: some View {
    switch locationAuthorization {
    case .allowed:
      if geocodingProgress < 1.0 {
        ProgressView(value: geocodingProgress)
          .progressViewStyle(.circular)
          .tint(.accentColor)
          #if os(macOS)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
          #endif
      }
    case .restricted:
      ContentUnavailableView(
        String(
          localized: "Location Disabled", bundle: .module,
          comment: "Text shown when location services are restricted by user."),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are disabled.", bundle: .module,
          comment: "Description test when location services are restricted by user.")
      )
      .frame(height: 200)
    case .denied:
      ContentUnavailableView(
        String(
          localized: "Location Unavailable", bundle: .module,
          comment: "Text shown when location services are denied."),
        systemImage: "location.slash.circle",
        description: Text(
          "Location Services are not available.", bundle: .module,
          comment: "Description test when location services are denied.")
      )
      .frame(height: 200)
    }
  }

  func body(content: Content) -> some View {
    VStack {
      if locationFilter.isNearby {
        nearbyEnabledView
      }
      content
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Toggle(
          String(
            localized: "Filter Nearby", bundle: .module, comment: "Label for nearby filtering"),
          systemImage: "location.circle", isOn: $locationFilter.toggle)
      }
    }
  }
}

extension View {
  func locationFilter(
    _ locationFilter: Binding<LocationFilter>, geocodingProgress: Binding<Double>,
    locationAuthorization: Binding<LocationAuthorization>
  )
    -> some View
  {
    modifier(
      LocationFilterModifier(
        locationFilter: locationFilter, geocodingProgress: geocodingProgress,
        locationAuthorization: locationAuthorization))
  }
}

#Preview {
  Text("Enabled-Geocoding-Allowed")
    .locationFilter(
      .constant(.nearby), geocodingProgress: .constant(0),
      locationAuthorization: .constant(.allowed))
}

#Preview {
  Text(String("Enabled-Geocoding-Restricted"))
    .locationFilter(
      .constant(.nearby), geocodingProgress: .constant(0),
      locationAuthorization: .constant(.restricted))
}

#Preview {
  Text("Enabled-Geocoding-Denied")
    .locationFilter(
      .constant(.nearby), geocodingProgress: .constant(0), locationAuthorization: .constant(.denied)
    )
}
