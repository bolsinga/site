//
//  VenueMapFile.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/4/26.
//

import Foundation
import Shared

/// web_generator's venuemap.txt, with each picked place's MapKit identifier and street, and each
/// accepted address.
enum VenueMapFile {
  static var fileName: String { "venuemap.txt" }
  static var mapKitTag: String { "mapkit=" }

  /// `id*name*city*state`, then the street, URL and sortname when present, then the identifier.
  /// An accepted address gives the street, city and state, ahead of the pick's street and the
  /// archive's.
  static func line(for venue: Venue, pick: VenuePick?, address: VenueAddress? = nil) -> String {
    var fields = [
      venue.id, venue.name, address?.city ?? venue.location.city,
      address?.state ?? venue.location.state,
    ]
    let street = address.map { $0.street } ?? pick?.street ?? venue.location.street
    // Empty fields collapse when read, so only fields with values are written.
    fields += [street, venue.location.web?.absoluteString, venue.sortname].compactMap { $0 }
    switch pick {
    case .place(let identifier, _, _):
      fields.append(mapKitTag + identifier)
    case nil:
      // Unpicked venues keep the identifier the archive already has.
      if let mapKitID = venue.mapKitID { fields.append(mapKitTag + mapKitID) }
    case .coordinate:
      // TODO: Write pins once venuemap.txt has a coordinate field.
      break
    case .noPlace:
      break
    }
    return fields.joined(separator: "*")
  }

  /// Every venue, in ID order, one per line.
  static func contents(
    _ venues: [Venue], picks: [String: VenuePick], addresses: [String: VenueAddress] = [:]
  ) -> String {
    venues.sorted { $0.id.localizedStandardCompare($1.id) == .orderedAscending }
      .map { line(for: $0, pick: picks[$0.id], address: addresses[$0.id]) }
      .joined(separator: "\n") + "\n"
  }
}
