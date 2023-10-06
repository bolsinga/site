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
      Text(
        "Location Disabled", bundle: .module,
        comment: "Text shown when location services are restrictued by user.")
    case .denied:
      Text(
        "Location Unavailable", bundle: .module,
        comment: "Text shown when location services are denied.")
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
