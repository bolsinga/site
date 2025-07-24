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

  func mapItem(for venue: Venue) async throws -> MKMapItem {
    switch self {
    case .coordinate(let coordinate):
      return MKMapItem(
        venue: venue,
        location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    case .identifier(let string):
      guard let mapIdentifier = MKMapItem.Identifier(rawValue: string) else {
        throw PlacemarkError.noIdentifier
      }
      return try await MKMapItemRequest(mapItemIdentifier: mapIdentifier).mapItem
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
    }
  }
}
