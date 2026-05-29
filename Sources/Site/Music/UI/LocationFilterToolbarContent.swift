//
//  LocationFilterToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

#if canImport(UIKit)
  import UIKit

  extension UIDevice {
    fileprivate var showLocationFilterSettingsMenu: Bool {
      userInterfaceIdiom == .phone
    }
  }

  @MainActor
  private var showLocationFilterSettingsMenu: Bool {
    UIDevice.current.showLocationFilterSettingsMenu
  }
#else
  private let showLocationFilterSettingsMenu = false
#endif

extension LocationAuthorization {
  fileprivate var toggleSystemImage: String {
    switch self {
    case .allowed:
      "location.circle"
    case .restricted, .denied:
      "location.slash.circle"
    }
  }

  fileprivate func menuSystemImage(_ isNearby: Bool) -> String {
    switch self {
    case .allowed:
      isNearby ? "location.circle.fill" : "location.circle"
    case .restricted, .denied:
      isNearby ? "location.slash.circle.fill" : "location.slash.circle"
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
  let editNearbyDistanceAction: @MainActor () -> Void

  internal init(
    locationAuthorization: LocationAuthorization,
    placement: ToolbarItemPlacement = .primaryAction,
    editNearbyDistanceAction: @escaping @MainActor () -> Void
  ) {
    self.locationAuthorization = locationAuthorization
    self.placement = placement
    self.editNearbyDistanceAction = editNearbyDistanceAction
  }

  @ViewBuilder private var nearbyToggle: some View {
    @Bindable var bindableNearbyModel = nearbyModel
    Toggle(
      String(localized: "Filter Nearby"),
      systemImage: locationAuthorization.toggleSystemImage,
      isOn: $bindableNearbyModel.locationFilter.toggle
    )
    .disabled(locationAuthorization.uiDisabled)
  }

  @ViewBuilder private var nearbySettingsMenu: some View {
    Menu {
      Button {
        editNearbyDistanceAction()
      } label: {
        Label(
          String(localized: "Edit Nearby Distance"),
          systemImage: ArchiveCategory.settings.systemImage)
      }
    } label: {
      Label(
        String(localized: "Filter Nearby"),
        systemImage: locationAuthorization.menuSystemImage(nearbyModel.locationFilter.isNearby))
    } primaryAction: {
      nearbyModel.locationFilter.toggle.toggle()
    }
    .disabled(locationAuthorization.uiDisabled)
  }

  var body: some ToolbarContent {
    ToolbarItem(placement: placement) {
      if showLocationFilterSettingsMenu {
        nearbySettingsMenu
      } else {
        nearbyToggle
      }
    }
  }
}
