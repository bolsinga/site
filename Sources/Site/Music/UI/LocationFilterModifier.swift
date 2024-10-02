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
  let filteredDataIsEmpty: Bool
  // This is used to prevent @SceneStorage from being used in Previews.
  let loadLocationFilterFromStorage: Bool

  func body(content: Content) -> some View {
    @Bindable var bindableModel = model
    VStack {
      if model.locationFilter.isNearby {
        NearbyLocationView(model: model, filteredDataIsEmpty: filteredDataIsEmpty)
      }
      content
    }
    .toolbar { LocationFilterToolbarContent(isOn: $bindableModel.locationFilter.toggle) }
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
