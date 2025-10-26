//
//  Venue+Geocodable.swift
//
//
//  Created by Greg Bolsinga on 9/13/23.
//

import Foundation
import MapKit
import os

extension Logger {
  fileprivate static let geoToolbox = Logger(category: "geoToolbox")
}

extension Venue: AtlasGeocodable {
  private func geocodeToolbox() async throws -> Placemark {
    let item = try await MKMapItemRequest(placeDescriptor: placeDescriptor).mapItem

    guard let identifier = item.identifier else {
      return Placemark.coordinate(item.location.coordinate)
    }

    return Placemark.identifier(identifier.rawValue)
  }

  func geocode() async throws -> Placemark {
    // TODO: Add a way to use GeoToolbox
    //  - compare visually / programmatically with the MKGeocodingRequest.
    //  - This will allow the quality and / or logic to be double checked.
    let placemark: Placemark
    //    if useGeoToolbox {
    //      placemark = try await geocodeToolbox()
    //    } else {
    placemark = try await location.geocode()
    //    }
    Logger.geoToolbox.log("\(id, privacy: .public) - \(placemark, privacy: .public)")
    return placemark
  }
}
