//
//  VenuePick.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation

/// Where a venue was chosen to be.
enum VenuePick: Codable, Equatable, Sendable {
  /// A place in Maps, by its `MKMapItem.Identifier` string, with its address when it was picked.
  case place(identifier: String, address: String? = nil)
  /// A coordinate placed by hand, for a venue Maps doesn't know.
  case coordinate(latitude: Double, longitude: Double)
  /// No place can be found for the venue.
  case noPlace
}

extension VenuePick {
  /// The placemark the app would geocode the venue to with this pick; none for no place.
  var placemark: Placemark? {
    switch self {
    case .place(let identifier, _): .identifier(identifier)
    case .coordinate(let latitude, let longitude):
      .coordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    case .noPlace: nil
    }
  }
}

enum VenuePickStatus: CaseIterable, Sendable {
  case unpicked
  /// Unpicked, with an Auto-match suggestion to confirm.
  case suggested
  case picked
  /// Picked, and Verify All found it in Maps.
  case verified
  /// Picked, and Verify All found it moved to another identifier or gone.
  case stale
  case noPlace

  init(_ pick: VenuePick?) {
    switch pick {
    case nil: self = .unpicked
    case .place, .coordinate: self = .picked
    case .noPlace: self = .noPlace
    }
  }
}
