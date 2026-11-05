//
//  OpenInMapsButton.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/4/26.
//

import MapKit
import SwiftUI

/// Opens a map item in Maps.
struct OpenInMapsButton: View {
  let mapItem: MKMapItem?

  var body: some View {
    Button("Open in Maps", systemImage: "map") {
      #if !os(tvOS)
        mapItem?.openInMaps()
      #endif
    }
    .disabled(mapItem == nil)
  }
}
