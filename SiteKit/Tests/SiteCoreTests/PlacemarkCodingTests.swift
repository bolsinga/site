import CoreLocation
import Foundation
import Testing

@testable import SiteCore

struct PlacemarkCodingTests {
  private static let address = MapsAddress(street: "1 Main St", city: "c", cityAndState: "c, s")
  private static let coordinate = CLLocationCoordinate2D(latitude: 1.5, longitude: -2.5)

  // What was saved before the coding was written by hand.
  private static let saved: [(Placemark, String)] = [
    (
      .coordinate(coordinate, maps: address),
      #"{"coordinate":{"_0":{"latitude":1.5,"longitude":-2.5},"maps":{"city":"c","cityAndState":"c, s","street":"1 Main St"}}}"#
    ),
    (
      .coordinate(coordinate),
      #"{"coordinate":{"_0":{"latitude":1.5,"longitude":-2.5}}}"#
    ),
    (.identifier("I1"), #"{"identifier":{"_0":"I1"}}"#),
    (
      .place(identifier: "I1", coordinate: coordinate, maps: address),
      #"{"place":{"coordinate":{"latitude":1.5,"longitude":-2.5},"identifier":"I1","maps":{"city":"c","cityAndState":"c, s","street":"1 Main St"}}}"#
    ),
    (
      .place(identifier: "I1", coordinate: coordinate),
      #"{"place":{"coordinate":{"latitude":1.5,"longitude":-2.5},"identifier":"I1"}}"#
    ),
  ]

  @Test(arguments: saved)
  func writesWhatWasSaved(placemark: Placemark, json: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    #expect(String(decoding: try encoder.encode(placemark), as: UTF8.self) == json)
  }

  @Test(arguments: saved)
  func readsWhatWasSaved(placemark: Placemark, json: String) throws {
    let decoded = try JSONDecoder().decode(Placemark.self, from: Data(json.utf8))
    #expect(decoded.description == placemark.description)
    #expect(decoded.address == placemark.address)
  }

  @Test func anEmptyObjectIsNotAPlacemark() {
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(Placemark.self, from: Data("{}".utf8))
    }
  }
}
