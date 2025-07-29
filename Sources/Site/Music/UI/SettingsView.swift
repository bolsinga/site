//
//  SettingsView.swift
//  site
//
//  Created by Greg Bolsinga on 10/18/24.
//

import SwiftUI

struct SettingsView: View {
  @Environment(NearbyModel.self) var nearbyModel

  var body: some View {
    Form {
      Section(header: Text("Nearby Distance", bundle: .module)) {
        @Bindable var nb = nearbyModel
        NearbyDistanceThresholdView(distanceThreshold: $nb.distanceThreshold)
      }
      #if !os(macOS)
        Section(header: Text("About", bundle: .module)) {
          LabeledContent {
            Text(PackageBuild.info.version)
          } label: {
            Text("Version", bundle: .module)
          }
        }
      #endif
    }
  }
}

#Preview(traits: .modifier(NearbyPreviewModifer())) {
  SettingsView()
}
