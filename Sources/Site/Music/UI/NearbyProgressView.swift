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

  var body: some View {
    if locationAuthorization == .allowed && geocodingProgress < 1.0 {
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
  }
}

#Preview("Allowed Not Done") {
  NearbyProgressView(
    locationAuthorization: .allowed, geocodingProgress: 0)
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
