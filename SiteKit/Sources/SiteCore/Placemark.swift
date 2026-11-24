//
//  Placemark.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation
import MapKit

private enum PlacemarkError: Error {
  case noIdentifier
}

/// A coordinate as saved: its latitude and longitude.
private struct Coordinate: Codable {
  let latitude: Double
  let longitude: Double

  init(_ coordinate: CLLocationCoordinate2D) {
    latitude = coordinate.latitude
    longitude = coordinate.longitude
  }

  var value: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

public enum Placemark: Sendable {
  /// Where Maps found the address, with the address it gave.
  package static func found(_ item: MKMapItem) -> Placemark {
    .coordinate(item.location.coordinate, maps: MapsAddress(item))
  }

  /// Where an address is; the address Maps gave is none in places cached before it was kept as
  /// it is now.
  case coordinate(CLLocationCoordinate2D, maps: MapsAddress? = nil)
  case identifier(String)
  /// A place in Maps with where it is, so showing it needs no lookup.
  case place(identifier: String, coordinate: CLLocationCoordinate2D, maps: MapsAddress? = nil)

  /// The address Maps gave, if it was kept.
  package var address: MapsAddress? {
    switch self {
    case .coordinate(_, let address), .place(_, _, let address): address
    case .identifier: nil
    }
  }

  public func mapItem(for venue: Venue) async throws -> MKMapItem {
    switch self {
    case .coordinate(let coordinate, _), .place(_, let coordinate, _):
      return MKMapItem(
        venue: venue,
        location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    case .identifier(let string):
      guard let mapIdentifier = MKMapItem.Identifier(rawValue: string) else {
        throw PlacemarkError.noIdentifier
      }
      return try await MapItemLookup.mapItem(for: mapIdentifier)
    }
  }
}

extension Placemark {
  /// How the place was found, for logs.
  package var origin: String {
    switch self {
    case .coordinate: "address"
    case .identifier(let string), .place(let string, _, _): "MapKit identifier \(string)"
    }
  }
}

extension Placemark: CustomStringConvertible {
  public var description: String {
    switch self {
    case .coordinate(let coordinate, _):
      "\(coordinate)"
    case .identifier(let string):
      string
    case .place(let identifier, let coordinate, _):
      "\(identifier) \(coordinate)"
    }
  }
}

/// Saved as the compiler would have written it, so places cached before this was written still read.
extension Placemark: Codable {
  private enum CodingKeys: String, CodingKey {
    case coordinate, identifier, place
  }

  private enum CoordinateKeys: String, CodingKey {
    case _0, maps
  }

  private enum IdentifierKeys: String, CodingKey {
    case _0
  }

  private enum PlaceKeys: String, CodingKey {
    case identifier, coordinate, maps
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.coordinate) {
      let nested = try container.nestedContainer(keyedBy: CoordinateKeys.self, forKey: .coordinate)
      self = .coordinate(
        try nested.decode(Coordinate.self, forKey: ._0).value,
        maps: try nested.decodeIfPresent(MapsAddress.self, forKey: .maps))
    } else if container.contains(.identifier) {
      let nested = try container.nestedContainer(keyedBy: IdentifierKeys.self, forKey: .identifier)
      self = .identifier(try nested.decode(String.self, forKey: ._0))
    } else if container.contains(.place) {
      let nested = try container.nestedContainer(keyedBy: PlaceKeys.self, forKey: .place)
      self = .place(
        identifier: try nested.decode(String.self, forKey: .identifier),
        coordinate: try nested.decode(Coordinate.self, forKey: .coordinate).value,
        maps: try nested.decodeIfPresent(MapsAddress.self, forKey: .maps))
    } else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "No placemark case."))
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .coordinate(let coordinate, let maps):
      var nested = container.nestedContainer(keyedBy: CoordinateKeys.self, forKey: .coordinate)
      try nested.encode(Coordinate(coordinate), forKey: ._0)
      try nested.encodeIfPresent(maps, forKey: .maps)
    case .identifier(let identifier):
      var nested = container.nestedContainer(keyedBy: IdentifierKeys.self, forKey: .identifier)
      try nested.encode(identifier, forKey: ._0)
    case .place(let identifier, let coordinate, let maps):
      var nested = container.nestedContainer(keyedBy: PlaceKeys.self, forKey: .place)
      try nested.encode(identifier, forKey: .identifier)
      try nested.encode(Coordinate(coordinate), forKey: .coordinate)
      try nested.encodeIfPresent(maps, forKey: .maps)
    }
  }
}
