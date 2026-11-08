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
  /// Wide enough for the sidebar and every toolbar item, with the filter's segments, to show.
  static var defaultWindowSize: CGSize { CGSize(width: 1280, height: 820) }

  /// Where the window first opens: its default size, kept on the screen, and centered.
  static func defaultWindowPlacement(in display: CGRect) -> CGRect {
    let size = CGSize(
      width: min(defaultWindowSize.width, display.width),
      height: min(defaultWindowSize.height, display.height))
    return CGRect(
      x: display.midX - size.width / 2.0, y: display.midY - size.height / 2.0,
      width: size.width, height: size.height)
  }

  /// The name the window's frame is saved under.
  static var windowFrameName: String { "VenuePlaces" }

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
