//
//  NearbyDistanceThresholdToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct NearbyDistanceThresholdToolbarContent: ToolbarContent {
  let placement: ToolbarItemPlacement
  let model: NearbyModel

  @State private var presentDistanceSliderPopover = false

  internal init(placement: ToolbarItemPlacement = .primaryAction, model: NearbyModel) {
    self.placement = placement
    self.model = model
  }

  var body: some ToolbarContent {
    ToolbarItem(placement: placement) {
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
