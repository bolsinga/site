//
//  SettingsView.swift
//  site
//
//  Created by Greg Bolsinga on 10/18/24.
//

import SwiftUI

public struct SettingsView: View {
  public init() {}

  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  public var body: some View {
    Form {
      Section(header: Text("Nearby Distance")) {
        NearbyDistanceThresholdView(distanceThreshold: $nearbyDistance)
      }
      #if !os(macOS)
        Section(header: Text("About")) {
          LabeledContent {
            Text(PackageBuild.info.version)
          } label: {
            Text("Version")
          }
        }
      #endif
    }
  }
}

#Preview {
  SettingsView()
}
