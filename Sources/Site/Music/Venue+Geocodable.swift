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
      do {
        let item = try await Placemark.identifier(mapKitID).mapItem(for: self)
        placemark = .place(
          identifier: mapKitID, coordinate: item.location.coordinate, address: MapsAddress(item))
      } catch {
        // Placed by its address until a later launch finds the identifier.
        Logger.geoToolbox.error(
          "\(id, privacy: .public) - \(mapKitID, privacy: .public): \(error, privacy: .public)")
        placemark = try await location.geocode()
      }
    } else {
      placemark = try await location.geocode()
    }
    Logger.geoToolbox.log("\(id, privacy: .public) - \(placemark, privacy: .public)")
    return placemark
  }

  /// Its address and MapKit identifier, so a venue that moves or gets an identifier is found again.
  var geocodeSource: String? {
    [location.addressString, mapKitID].compactMap { $0 }.joined(separator: "\n")
  }

  /// A venue with a MapKit identifier uses the place found for it, not one from its address. A
  /// place cached without the address Maps gave is found again, to keep it.
  func canUseCached(_ place: Placemark) -> Bool {
    guard place.address != nil else { return false }
    guard let mapKitID else { return true }
    guard case .place(let identifier, _, _) = place else { return false }
    return identifier == mapKitID
  }
}
