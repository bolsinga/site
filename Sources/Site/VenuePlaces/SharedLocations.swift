//
//  SharedLocations.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import CoreLocation
import Shared

/// Venues that geocode to the same point.
struct SharedLocation: Identifiable {
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

  /// Venues this close to a group's first venue share its point.
  static var sharedDistance: CLLocationDistance { 1 }

  /// Where the group's first venue is.
  let location: CLLocation
  /// The venues, in the order given.
  let venues: [Member]

  /// The group's first venue, which stays first.
  var id: ArchivePath { venues[0].id }

  var coordinate: CLLocationCoordinate2D { location.coordinate }

  var cause: Cause {
    if venues.allSatisfy({ $0.location.street == nil }) { return .noStreet }
    if Set(venues.map(\.location.addressString)).count == 1 { return .sameAddress }
    return .vagueAddress
  }

  /// The groups of two or more venues at one point, the biggest first.
  static func groups(
    of venues: [Member], location: (ArchivePath) -> CLLocation?
  ) -> [SharedLocation] {
    var groups = [(location: CLLocation, venues: [Member])]()
    for venue in venues {
      guard let venueLocation = location(venue.id) else { continue }
      if let index = groups.firstIndex(where: {
        $0.location.distance(from: venueLocation) <= sharedDistance
      }) {
        groups[index].venues.append(venue)
      } else {
        groups.append((venueLocation, [venue]))
      }
    }
    // The sort is stable, so ties stay in the order their first venue was given.
    return groups.filter { $0.venues.count > 1 }
      .map { SharedLocation(location: $0.location, venues: $0.venues) }
      .sorted { $0.venues.count > $1.venues.count }
  }
}
