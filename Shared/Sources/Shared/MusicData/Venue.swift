//
//  Venue.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Venue: Codable, Equatable, Hashable, Identifiable, Sendable {
  public let id: String
  public let location: Location
  public let name: String
  public let sortname: String?
  /// The venue's place in Maps, as an `MKMapItem.Identifier` string.
  public let mapKitID: String?

  enum CodingKeys: String, CodingKey {
    case id
    case location
    case name
    case sortname
    case mapKitID = "mapkit"
  }

  public init(
    id: String, location: Location, name: String, sortname: String? = nil, mapKitID: String? = nil
  ) {
    self.id = id
    self.location = location
    self.name = name
    self.sortname = sortname
    self.mapKitID = mapKitID
  }
}
