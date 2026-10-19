//
//  NearbyProgressView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/16/25.
//

import SwiftUI

struct NearbyProgressView: View {
  let locationAuthorization: LocationAuthorization
  let geocodingProgress: Double

  /// In a capsule, to be shown over content instead of above it.
  var floating = false

  private var progress: some View {
    HStack {
      ProgressView(value: geocodingProgress)
        .progressViewStyle(.circular)
        .tint(.accentColor)
        #if os(macOS)
          .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        #endif
      Text("Geocoding…")
        .font(.headline)
    }
  }

  @ViewBuilder var body: some View {
    if locationAuthorization == .allowed && geocodingProgress < 1.0 {
      if floating {
        progress
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(.regularMaterial, in: .capsule)
          .padding(.top, 8)
      } else {
        progress
      }
    }
  }
}

#Preview("Allowed Not Done") {
  NearbyProgressView(
    locationAuthorization: .allowed, geocodingProgress: 0)
}

#Preview("Allowed Not Done Floating") {
  NearbyProgressView(
    locationAuthorization: .allowed, geocodingProgress: 0, floating: true)
}

#Preview("Allowed Done") {
  NearbyProgressView(
    locationAuthorization: .allowed, geocodingProgress: 1)
}

#Preview("Not Allowed Not Done") {
  NearbyProgressView(
    locationAuthorization: .restricted, geocodingProgress: 0)
}

#Preview("Not Allowed Done") {
  NearbyProgressView(
    locationAuthorization: .restricted, geocodingProgress: 1)
}
