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

struct LocationFilterToolbarContent: ToolbarContent {
  let placement: ToolbarItemPlacement
  @Environment(NearbyModel.self) var nearbyModel
  let editNearbyDistanceAction: @MainActor () -> Void

  internal init(
    placement: ToolbarItemPlacement = .primaryAction,
    editNearbyDistanceAction: @escaping @MainActor () -> Void
  ) {
    self.placement = placement
    self.editNearbyDistanceAction = editNearbyDistanceAction
  }

  @ViewBuilder private var nearbyToggle: some View {
    @Bindable var bindableNearbyModel = nearbyModel
    Toggle(
      String(localized: "Filter Nearby", bundle: .module), systemImage: "location.circle",
      isOn: $bindableNearbyModel.locationFilter.toggle)
  }

  @ViewBuilder private var nearbySettingsMenu: some View {
    Menu {
      Button {
        editNearbyDistanceAction()
      } label: {
        Label(
          String(localized: "Edit Nearby Distance", bundle: .module),
          systemImage: ArchiveCategory.settings.systemImage)
      }
    } label: {
      Label(
        String(localized: "Filter Nearby", bundle: .module),
        systemImage: nearbyModel.locationFilter.isNearby
          ? "location.circle.fill" : "location.circle")
    } primaryAction: {
      nearbyModel.locationFilter.toggle.toggle()
    }
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
