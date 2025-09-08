//
//  SettingsView.swift
//  site
//
//  Created by Greg Bolsinga on 10/18/24.
//

import SwiftUI

extension Bundle {
  fileprivate var buildNumber: String {
    guard let value = object(forInfoDictionaryKey: "CFBundleVersion"), let vers = value as? String
    else { return "Unknown" }
    return vers
  }

  fileprivate var shortVersion: String {
    guard let value = object(forInfoDictionaryKey: "CFBundleShortVersionString"),
      let vers = value as? String
    else { return "Unknown" }
    return vers
  }

  fileprivate var version: String {
    "\(shortVersion) (\(buildNumber))"
  }
}

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
            Text(Bundle.main.version)
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
