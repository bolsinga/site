//
//  Placemark.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation
import MapKit
import Shared

private enum PlacemarkError: Error {
  case noIdentifier
}

private enum Keys: String, CodingKey {
  case latitude
  case longitude
}

extension CLLocationCoordinate2D: @retroactive Decodable {
  public init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: Keys.self)
    let latitude = try values.decode(Double.self, forKey: .latitude)
    let longitude = try values.decode(Double.self, forKey: .longitude)
    self.init(latitude: latitude, longitude: longitude)
  }
}

extension CLLocationCoordinate2D: @retroactive Encodable {
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: Keys.self)
    try container.encode(latitude, forKey: .latitude)
    try container.encode(longitude, forKey: .longitude)
  }
}

enum Placemark: Codable {
  /// Where Maps found the address, with the address it gave.
  static func found(_ item: MKMapItem) -> Placemark {
    .coordinate(item.location.coordinate, address: MapsAddress(item))
  }

  /// Where an address is; the address Maps gave is none in places cached before it was kept.
  case coordinate(CLLocationCoordinate2D, address: MapsAddress? = nil)
  case identifier(String)
  /// A place in Maps with where it is, so showing it needs no lookup.
  case place(identifier: String, coordinate: CLLocationCoordinate2D, address: MapsAddress? = nil)

  /// The address Maps gave, if it was kept.
  var address: MapsAddress? {
    switch self {
    case .coordinate(_, let address), .place(_, _, let address): address
    case .identifier: nil
    }
  }

  func mapItem(for venue: Venue) async throws -> MKMapItem {
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
  var origin: String {
    switch self {
    case .coordinate: "address"
    case .identifier(let string), .place(let string, _, _): "MapKit identifier \(string)"
    }
  }
}

extension Placemark: CustomStringConvertible {
  var description: String {
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
