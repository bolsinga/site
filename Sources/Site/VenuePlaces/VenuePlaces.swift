//
//  VenuePlaces.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation
import MapKit
import SwiftUI

/// Choosing where each venue is on the map; built everywhere, but only runs in Debug on macOS.
enum VenuePlaces {
  static let windowID = "venue-places"

  static var isEnabled: Bool {
    #if DEBUG && os(macOS)
      true
    #else
      false
    #endif
  }
}

extension VenuePlaces {
  /// Panning and zooming, without tilting.
  static var mapInteractionModes: MapInteractionModes { [.pan, .zoom, .rotate] }
}

extension View {
  /// A flat map with buttons to zoom, since scrolling in a form scrolls the form.
  func venuePlacesMap() -> some View {
    self
      .mapStyle(.standard(elevation: .flat))
      .mapControls {
        #if os(macOS)
          MapZoomStepper()
        #endif
        MapCompass()
        MapScaleView()
      }
  }
}
