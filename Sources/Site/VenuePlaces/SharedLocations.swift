//
//  SharedLocations.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import Shared

/// Venues that geocode to the same point.
struct SharedLocation: Identifiable, Hashable {
  /// The point, rounded so that venues within about a meter share it.
  struct Key: Hashable {
    let latitude: Int
    let longitude: Int

    /// Five decimal places of a degree is about a meter.
    private static var scale: Double { 100_000 }

    init(_ coordinate: CLLocationCoordinate2D) {
      latitude = Int((coordinate.latitude * Self.scale).rounded())
      longitude = Int((coordinate.longitude * Self.scale).rounded())
    }

    var coordinate: CLLocationCoordinate2D {
      CLLocationCoordinate2D(
        latitude: Double(latitude) / Self.scale, longitude: Double(longitude) / Self.scale)
    }
  }

  enum Cause: Hashable {
    /// None of the venues has a street, so they geocode to the center of their city.
    case noStreet
    /// The venues have the same address.
    case sameAddress
    /// The venues have different addresses, at least one too vague to tell apart.
    case vagueAddress
  }

  struct Member: Hashable {
    let id: ArchivePath
    let location: Location
  }

  let id: Key
  /// The venues, in the order given.
  let venues: [Member]

  var coordinate: CLLocationCoordinate2D { id.coordinate }

  var cause: Cause {
    if venues.allSatisfy({ $0.location.street == nil }) { return .noStreet }
    if Set(venues.map(\.location.addressString)).count == 1 { return .sameAddress }
    return .vagueAddress
  }

  /// The groups of two or more venues at one point, the biggest first.
  static func groups(
    of venues: [Member], coordinate: (ArchivePath) -> CLLocationCoordinate2D?
  ) -> [SharedLocation] {
    var keys = [Key]()
    var grouped = [Key: [Member]]()
    for venue in venues {
      guard let coordinate = coordinate(venue.id) else { continue }
      let key = Key(coordinate)
      if grouped[key] == nil { keys.append(key) }
      grouped[key, default: []].append(venue)
    }
    // The sort is stable, so ties stay in the order their first venue was given.
    return keys.compactMap { key in
      guard let venues = grouped[key], venues.count > 1 else { return nil }
      return SharedLocation(id: key, venues: venues)
    }
    .sorted { $0.venues.count > $1.venues.count }
  }
}
