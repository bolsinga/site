//
//  VenuePick.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation

/// Where a venue was chosen to be.
enum VenuePick: Codable, Equatable, Sendable {
  /// A place in Maps, by its `MKMapItem.Identifier` string.
  case place(identifier: String)
  /// A coordinate placed by hand, for a venue Maps doesn't know.
  case coordinate(latitude: Double, longitude: Double)
  /// No place can be found for the venue.
  case noPlace
}

enum VenuePickStatus: CaseIterable, Sendable {
  case unpicked
  case picked
  case noPlace

  init(_ pick: VenuePick?) {
    switch pick {
    case nil: self = .unpicked
    case .place, .coordinate: self = .picked
    case .noPlace: self = .noPlace
    }
  }
}
