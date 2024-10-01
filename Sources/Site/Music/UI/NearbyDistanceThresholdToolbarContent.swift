//
//  NearbyDistanceThresholdToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct NearbyDistanceThresholdToolbarContent: ToolbarContent {
  let model: NearbyModel

  @State private var presentDistanceSliderPopover = false

  var body: some ToolbarContent {
    ToolbarItem(placement: .primaryAction) {
      @Bindable var model = model
      let labelText = Text("Nearby Distance", bundle: .module)
      Button {
        presentDistanceSliderPopover = true
      } label: {
        Label {
          labelText
        } icon: {
          Image(systemName: "gear")
        }
      }
      .popover(isPresented: $presentDistanceSliderPopover) {
        NearbyDistanceThresholdView(distanceThreshold: $model.distanceThreshold) {
          labelText
        }
        .presentationCompactAdaptation(.popover)
      }
    }
  }
}
