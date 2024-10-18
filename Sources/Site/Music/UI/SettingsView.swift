//
//  SettingsView.swift
//  site
//
//  Created by Greg Bolsinga on 10/18/24.
//

import SwiftUI

struct SettingsView: View {
  let nearbyModel: NearbyModel

  var body: some View {
    Form {
      Section(header: Text("Nearby Distance", bundle: .module)) {
        @Bindable var nb = nearbyModel
        NearbyDistanceThresholdView(distanceThreshold: $nb.distanceThreshold)
      }
    }
  }
}

#Preview {
  SettingsView(nearbyModel: NearbyModel())
}
