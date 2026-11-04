//
//  VenueMapFile.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/4/26.
//

import Foundation
import Shared

/// web_generator's venuemap.txt, with each picked place's MapKit identifier and street.
enum VenueMapFile {
  static var fileName: String { "venuemap.txt" }
  static var mapKitTag: String { "mapkit=" }

  /// `id*name*city*state`, then the street, URL and sortname when present, then the identifier.
  static func line(for venue: Venue, pick: VenuePick?) -> String {
    var fields = [venue.id, venue.name, venue.location.city, venue.location.state]
    // Empty fields collapse when read, so only fields with values are written.
    fields += [
      pick?.street ?? venue.location.street, venue.location.web?.absoluteString, venue.sortname,
    ].compactMap { $0 }
    switch pick {
    case .place(let identifier, _, _):
      fields.append(mapKitTag + identifier)
    case .coordinate:
      // TODO: Write pins once venuemap.txt has a coordinate field.
      break
    case .noPlace, nil:
      break
    }
    return fields.joined(separator: "*")
  }

  /// Every venue, in ID order, one per line.
  static func contents(_ venues: [Venue], picks: [String: VenuePick]) -> String {
    venues.sorted { $0.id.localizedStandardCompare($1.id) == .orderedAscending }
      .map { line(for: $0, pick: picks[$0.id]) }
      .joined(separator: "\n") + "\n"
  }
}
