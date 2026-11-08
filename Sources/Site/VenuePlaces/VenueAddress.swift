//
//  VenueAddress.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/26.
//

import Foundation
import Shared

/// A venue's street, city and state, as the archive has them or as Maps gave them.
struct VenueAddress: Codable, Equatable, Hashable, Sendable {
  let street: String?
  let city: String
  let state: String
}

extension VenueAddress {
  init(_ location: Location) {
    self.init(street: location.street, city: location.city, state: location.state)
  }

  /// Maps' address, with the state from its "City, ST"; none when Maps gave no city.
  init?(_ maps: MapsAddress) {
    guard let city = maps.city, let cityAndState = maps.cityAndState,
      cityAndState.hasPrefix(city + ", ")
    else { return nil }
    self.init(
      street: maps.street, city: city, state: String(cityAndState.dropFirst(city.count + 2)))
  }

  /// The address on one line, as the venue shows it.
  var formatted: String {
    [street, "\(city), \(state)"].compactMap { $0 }.joined(separator: ", ")
  }
}

/// How a venue's address compares with the one Maps gave, as one line of text, so accepting
/// Maps' makes the venue's match it exactly.
enum AddressCheck: Equatable, Sendable {
  case matches
  /// Maps gave a different address, which accepting makes the venue's.
  case differs(VenueAddress)
  /// Maps gave no address that can be compared.
  case unknown

  init(venue: VenueAddress, maps: MapsAddress?) {
    guard let maps, let found = VenueAddress(maps) else {
      self = .unknown
      return
    }
    self = venue.formatted == found.formatted ? .matches : .differs(found)
  }
}
