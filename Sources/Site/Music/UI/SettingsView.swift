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

  private var nearbyDistanceControl: some View {
    NearbyDistanceThresholdView(distanceThreshold: $nearbyDistance)
  }

  private var computerView: some View {
    ComputerView()
      .accentReactsToInteractionSpeed()
      .frame(width: 240)
  }

  #if os(macOS)
    // Form expands to fill a resizable window, which prevents the
    // Settings window from sizing tightly to its content.
    public var body: some View {
      VStack(spacing: 20) {
        VStack {
          Text("Nearby Distance").font(.headline)
          nearbyDistanceControl
        }
        computerView
      }
      .padding()
    }
  #else
    public var body: some View {
      Form {
        Section(header: Text("Nearby Distance")) {
          nearbyDistanceControl
        }
        Section {
          // Form rows don't center their content by default.
          computerView
            .frame(maxWidth: .infinity)
        }
        Section(header: Text("About")) {
          LabeledContent {
            Text(Bundle.main.version)
          } label: {
            Text("Version")
          }
        }
      }
    }
  #endif
}

#Preview {
  SettingsView()
}
