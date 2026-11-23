//
//  SettingsView.swift
//  site
//
//  Created by Greg Bolsinga on 10/18/24.
//

import CoreLocation
import SiteCore
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

  @NearbyDistanceStorage private var nearbyDistance

  @Environment(NearbyModel.self) private var nearbyModel: NearbyModel?

  @ViewBuilder private var cityControl: some View {
    if nearbyModel != nil {
      CityNameField()
    }
  }

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
          Text("Nearby Distance", bundle: #bundle).font(.headline)
          nearbyDistanceControl
        }
        if nearbyModel != nil {
          VStack {
            Text("City", bundle: #bundle).font(.headline)
            cityControl
          }
        }
        computerView
      }
      .padding()
    }
  #else
    public var body: some View {
      Form {
        Section(header: Text("Nearby Distance", bundle: #bundle)) {
          nearbyDistanceControl
        }
        if nearbyModel != nil {
          Section(header: Text("City", bundle: #bundle)) {
            cityControl
          }
        }
        Section {
          // Form rows don't center their content by default.
          computerView
            .frame(maxWidth: .infinity)
        }
        Section(header: Text("About", bundle: #bundle)) {
          LabeledContent {
            Text(Bundle.main.version)
          } label: {
            Text("Version", bundle: #bundle)
          }
        }
      }
    }
  #endif
}

#Preview {
  SettingsView()
}
