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

public enum Placemark: Codable, Sendable {
  /// A point on the map as it is saved: its latitude and longitude.
  public struct Coordinate: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
      self.latitude = latitude
      self.longitude = longitude
    }

    init(_ coordinate: CLLocationCoordinate2D) {
      self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
  }

  /// Where Maps found the address, with the address it gave.
  package static func found(_ item: MKMapItem) -> Placemark {
    .coordinate(Coordinate(item.location.coordinate), maps: MapsAddress(item))
  }

  /// Where an address is; the address Maps gave is none in places cached before it was kept as
  /// it is now.
  case coordinate(Coordinate, maps: MapsAddress? = nil)
  case identifier(String)
  /// A place in Maps with where it is, so showing it needs no lookup.
  case place(identifier: String, coordinate: Coordinate, maps: MapsAddress? = nil)

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
