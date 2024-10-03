//
//  LocationFilterModifier.swift
//
//
//  Created by Greg Bolsinga on 10/5/23.
//

import SwiftUI

struct LocationFilterModifier: ViewModifier {
  @SceneStorage("nearby.filter") private var locationFilter = LocationFilter.none

  let model: NearbyModel
  let locationAuthorization: LocationAuthorization
  let geocodingProgress: Double
  let filteredDataIsEmpty: Bool

  func body(content: Content) -> some View {
    @Bindable var bindableModel = model
    VStack {
      if model.locationFilter.isNearby {
        NearbyLocationView(
          locationAuthorization: locationAuthorization, geocodingProgress: geocodingProgress,
          filteredDataIsEmpty: filteredDataIsEmpty)
      }
      content
    }
    .toolbar { LocationFilterToolbarContent(isOn: $bindableModel.locationFilter.toggle) }
    .task {
      model.locationFilter = locationFilter
    }
    .onChange(of: model.locationFilter) { _, newValue in
      locationFilter = newValue
    }
  }
}

extension View {
  func locationFilter(
    _ model: NearbyModel, locationAuthorization: LocationAuthorization, geocodingProgress: Double,
    filteredDataIsEmpty: Bool
  ) -> some View {
    modifier(
      LocationFilterModifier(
        model: model, locationAuthorization: locationAuthorization,
        geocodingProgress: geocodingProgress, filteredDataIsEmpty: filteredDataIsEmpty))
  }
}
