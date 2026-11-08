//
//  MapsAddress.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/26.
//

import MapKit

/// The address Maps gave a place it found, kept so it can be compared with a venue's own.
struct MapsAddress: Codable, Equatable, Hashable, Sendable {
  /// The address's lines without the country, such as the street, then the city, state and code.
  let lines: [String]
  let city: String?
}

extension MapsAddress {
  /// The item's address; empty when Maps gave it none.
  init(_ item: MKMapItem) {
    let representations = item.addressRepresentations
    let lines = representations?.fullAddress(includingRegion: false, singleLine: false)?
      .split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
    self.init(lines: lines ?? [], city: representations?.cityName)
  }
}
