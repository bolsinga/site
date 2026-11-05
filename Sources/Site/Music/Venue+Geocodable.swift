//
//  Venue+Geocodable.swift
//
//
//  Created by Greg Bolsinga on 9/13/23.
//

import Foundation
import MapKit
import Shared
import os

extension Logger {
  fileprivate static let geoToolbox = Logger(category: "geoToolbox")
}

extension Venue: AtlasGeocodable {
  /// The place Maps resolves the venue's name and address to.
  func toolboxMapItem() async throws -> MKMapItem {
    try await MKMapItemRequest(placeDescriptor: placeDescriptor).mapItem
  }

  func geocode() async throws -> Placemark {
    let placemark: Placemark
    if let mapKitID {
      placemark = .identifier(mapKitID)
    } else {
      placemark = try await location.geocode()
    }
    Logger.geoToolbox.log("\(id, privacy: .public) - \(placemark, privacy: .public)")
    return placemark
  }

  /// A venue with a MapKit identifier uses it, not a place cached from its address.
  func canUseCached(_ place: Placemark) -> Bool {
    guard let mapKitID else { return true }
    guard case .identifier(let identifier) = place else { return false }
    return identifier == mapKitID
  }
}
