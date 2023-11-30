//
//  LocationFilterModifier.swift
//
//
//  Created by Greg Bolsinga on 10/5/23.
//

import SwiftUI

struct LocationFilterModifier: ViewModifier {
  @SceneStorage("nearby.filter") private var locationFilter = LocationFilter.none

  var model: NearbyModel
  let filteredDataIsEmpty: Bool
  // This is used to prevent @SceneStorage from being used in Previews.
  let loadLocationFilterFromStorage: Bool

  @ViewBuilder private var nearbyEnabledView: some View {
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

  func body(content: Content) -> some View {
    @Bindable var model = model
    VStack {
      if model.locationFilter.isNearby {
        nearbyEnabledView
      }
      content
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Toggle(
          String(localized: "Filter Nearby", bundle: .module),
          systemImage: "location.circle", isOn: $model.locationFilter.toggle)
      }
    }
    .task {
      guard loadLocationFilterFromStorage else { return }
      model.locationFilter = locationFilter
    }
    .onChange(of: model.locationFilter) { _, newValue in
      locationFilter = newValue
    }
  }
}

extension View {
  func locationFilter(
    _ model: NearbyModel, filteredDataIsEmpty: Bool, loadLocationFilterFromStorage: Bool = true
  ) -> some View {
    modifier(
      LocationFilterModifier(
        model: model, filteredDataIsEmpty: filteredDataIsEmpty,
        loadLocationFilterFromStorage: loadLocationFilterFromStorage))
  }
}

#Preview {
  Text("Enabled-Geocoding-Allowed")
    .locationFilter(
      NearbyModel(locationFilter: .nearby, locationAuthorization: .allowed, geocodingProgress: 0),
      filteredDataIsEmpty: true, loadLocationFilterFromStorage: false)
}

#Preview {
  Text("Enabled-Geocoding-Allowed-Empty")
    .locationFilter(
      NearbyModel(locationFilter: .nearby, locationAuthorization: .allowed, geocodingProgress: 1),
      filteredDataIsEmpty: true, loadLocationFilterFromStorage: false)
}

#Preview {
  Text(String("Enabled-Geocoding-Restricted"))
    .locationFilter(
      NearbyModel(
        locationFilter: .nearby, locationAuthorization: .restricted, geocodingProgress: 0),
      filteredDataIsEmpty: false, loadLocationFilterFromStorage: false)
}

#Preview {
  Text("Enabled-Geocoding-Denied")
    .locationFilter(
      NearbyModel(locationFilter: .nearby, locationAuthorization: .denied, geocodingProgress: 1),
      filteredDataIsEmpty: false, loadLocationFilterFromStorage: false)
}
