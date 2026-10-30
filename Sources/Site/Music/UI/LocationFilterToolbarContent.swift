//
//  LocationFilterToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import Shared
import SwiftUI

extension LocationAuthorization {
  fileprivate func menuSystemImage(_ filter: LocationFilter, mode: LocationFilter) -> String {
    switch mode {
    case .city:
      filter.isActive ? "building.2.crop.circle.fill" : "building.2.crop.circle"
    case .none, .nearby:
      switch self {
      case .allowed:
        filter.isActive ? "location.circle.fill" : "location.circle"
      case .restricted, .denied:
        filter.isActive ? "location.slash.circle.fill" : "location.slash.circle"
      }
    }
  }

  fileprivate var uiDisabled: Bool {
    switch self {
    case .allowed, .denied:
      false
    case .restricted:
      true
    }
  }
}

struct LocationFilterToolbarContent: ToolbarContent {
  let locationAuthorization: LocationAuthorization
  let placement: ToolbarItemPlacement
  @Environment(NearbyModel.self) var nearbyModel
  let editSettingsAction: @MainActor () -> Void

  internal init(
    locationAuthorization: LocationAuthorization,
    placement: ToolbarItemPlacement = .primaryAction,
    editSettingsAction: @escaping @MainActor () -> Void
  ) {
    self.locationAuthorization = locationAuthorization
    self.placement = placement
    self.editSettingsAction = editSettingsAction
  }

  private var title: String {
    nearbyModel.mode.isCity ? String(localized: "Filter City") : String(localized: "Filter Nearby")
  }

  @ViewBuilder private var modePicker: some View {
    @Bindable var bindableNearbyModel = nearbyModel
    Picker(String(localized: "Filter Mode"), selection: $bindableNearbyModel.mode) {
      Text("Nearby").tag(LocationFilter.nearby)
      Text("City").tag(LocationFilter.city)
    }
    .pickerStyle(.inline)
  }

  @ViewBuilder private var editButton: some View {
    Button {
      editSettingsAction()
    } label: {
      Label(
        nearbyModel.mode.isCity
          ? String(localized: "Edit City…") : String(localized: "Edit Nearby Distance"),
        systemImage: ArchiveCategory.settings.systemImage)
    }
  }

  var body: some ToolbarContent {
    ToolbarItem(placement: placement) {
      Menu {
        modePicker
        editButton
      } label: {
        Label(
          title,
          systemImage: locationAuthorization.menuSystemImage(
            nearbyModel.locationFilter, mode: nearbyModel.mode))
      } primaryAction: {
        nearbyModel.isOn.toggle()
      }
      .disabled(locationAuthorization.uiDisabled)
    }
  }
}
