//
//  VenuePlaces.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation

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
