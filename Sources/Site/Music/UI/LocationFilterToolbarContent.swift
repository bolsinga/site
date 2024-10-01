//
//  LocationFilterToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct LocationFilterToolbarContent: ToolbarContent {
  @Binding var isOn: Bool

  var body: some ToolbarContent {
    ToolbarItem(placement: .primaryAction) {
      Toggle(
        String(localized: "Filter Nearby", bundle: .module), systemImage: "location.circle",
        isOn: $isOn)
    }
  }
}
