//
//  LocationFilterToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct LocationFilterToolbarContent: ToolbarContent {
  let placement: ToolbarItemPlacement
  @Binding var isOn: Bool

  internal init(placement: ToolbarItemPlacement = .primaryAction, isOn: Binding<Bool>) {
    self.placement = placement
    self._isOn = isOn
  }

  var body: some ToolbarContent {
    ToolbarItem(placement: placement) {
      Toggle(
        String(localized: "Filter Nearby", bundle: .module), systemImage: "location.circle",
        isOn: $isOn)
    }
  }
}
