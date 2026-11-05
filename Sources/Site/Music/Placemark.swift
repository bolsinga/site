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
  static func coordinate(_ location: CLLocation) -> Placemark {
    .coordinate(location.coordinate)
  }

  case coordinate(CLLocationCoordinate2D)
  case identifier(String)
  /// A place in Maps with where it is, so showing it needs no lookup.
  case place(identifier: String, coordinate: CLLocationCoordinate2D)

  func mapItem(for venue: Venue) async throws -> MKMapItem {
    switch self {
    case .coordinate(let coordinate), .place(_, let coordinate):
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
    case .identifier(let string), .place(let string, _): "MapKit identifier \(string)"
    }
  }
}

extension Placemark: CustomStringConvertible {
  var description: String {
    switch self {
    case .coordinate(let coordinate):
      "\(coordinate)"
    case .identifier(let string):
      string
    case .place(let identifier, let coordinate):
      "\(identifier) \(coordinate)"
    }
  }
}
