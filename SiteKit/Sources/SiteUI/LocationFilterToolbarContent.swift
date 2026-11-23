//
//  LocationFilterToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import Shared
import SiteCore
import SwiftUI

extension LocationAuthorization {
  fileprivate func menuSystemImage(_ filter: LocationFilter, mode: LocationFilter) -> String {
    switch mode {
    case .city:
      filter.isActive ? "building.2.crop.circle.fill" : "building.2.crop.circle"
    case .none, .nearby:
      switch self {
      case .allowed, .notDetermined:
        filter.isActive ? "location.circle.fill" : "location.circle"
      case .restricted, .denied:
        filter.isActive ? "location.slash.circle.fill" : "location.slash.circle"
      }
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
    nearbyModel.mode.isCity
      ? String(localized: "Filter City", bundle: #bundle)
      : String(localized: "Filter Nearby", bundle: #bundle)
  }

  @ViewBuilder private var modePicker: some View {
    @Bindable var bindableNearbyModel = nearbyModel
    Picker(String(localized: "Filter Mode", bundle: #bundle), selection: $bindableNearbyModel.mode)
    {
      Text("Nearby To Me", bundle: #bundle).tag(LocationFilter.nearby)
      Text("City Limits", bundle: #bundle).tag(LocationFilter.city)
    }
    .pickerStyle(.inline)
  }

  @ViewBuilder private var editButton: some View {
    Button {
      editSettingsAction()
    } label: {
      Label(
        String(localized: "Edit Nearby Settings", bundle: #bundle),
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
      // macOS keeps the menu it first built, so a new mode rebuilds it to move the checkmark.
      .id(nearbyModel.mode)
      .accessibilityValue(
        nearbyModel.isOn
          ? String(localized: "On", bundle: #bundle) : String(localized: "Off", bundle: #bundle))
    }
  }
}
