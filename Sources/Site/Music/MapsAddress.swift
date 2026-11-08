//
//  MapsAddress.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/26.
//

import MapKit

/// The address Maps gave a place it found, kept so it can be compared with a venue's own.
struct MapsAddress: Codable, Equatable, Hashable, Sendable {
  /// The street, with any floor or suite; none when Maps found only the city.
  let street: String?
  let city: String?
  /// The city and state, such as "Portland, OR".
  let cityAndState: String?
}

extension MapsAddress {
  /// The item's address; empty when Maps gave it none.
  init(_ item: MKMapItem) {
    let representations = item.addressRepresentations
    let city = representations?.cityName
    // The short address is the street and the city, or only the city.
    let street = item.address?.shortAddress.flatMap { short in
      guard let city else { return short }
      let suffix = ", " + city
      return short.hasSuffix(suffix) ? String(short.dropLast(suffix.count)) : nil
    }
    self.init(
      street: street, city: city, cityAndState: representations?.cityWithContext(.short))
  }
}
