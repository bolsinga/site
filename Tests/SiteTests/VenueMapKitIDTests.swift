//
//  VenueMapKitIDTests.swift
//
//
//  Created by Greg Bolsinga on 11/4/26.
//

import CoreLocation
import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct VenueMapKitIDTests {
  let json = """
    {"id":"v144","location":{"city":"Portland","state":"OR"},"name":"Revolution Hall"
    """

  @Test func decodesMapKitID() throws {
    let venue = try JSONDecoder().decode(
      Venue.self, from: Data((json + ",\"mapkit\":\"IC053CE05CC449DA0\"}").utf8))
    #expect(venue.mapKitID == "IC053CE05CC449DA0")
  }

  @Test func decodesWithoutMapKitID() throws {
    let venue = try JSONDecoder().decode(Venue.self, from: Data((json + "}").utf8))
    #expect(venue.mapKitID == nil)
  }

  @Test func encodesMapKitIDAsMapkit() throws {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    let object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(venue))
    #expect((object as? [String: Any])?["mapkit"] as? String == "I1")
  }

  @Test func geocodesToMapKitID() async throws {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    guard case .identifier(let identifier) = try await venue.geocode() else {
      Issue.record("not an identifier")
      return
    }
    #expect(identifier == "I1")
  }

  @Test func cachedAddressGivesWayToMapKitID() {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    #expect(!venue.isCurrent(.coordinate(CLLocationCoordinate2D(latitude: 1, longitude: 2))))
    #expect(!venue.isCurrent(.identifier("I2")))
    #expect(venue.isCurrent(.identifier("I1")))
  }

  @Test func cacheHoldsWithoutMapKitID() {
    let venue = Venue(id: "v1", location: Location(city: "c", state: "s"), name: "n")
    #expect(venue.isCurrent(.coordinate(CLLocationCoordinate2D(latitude: 1, longitude: 2))))
  }

  @Test func unpickedVenueKeepsArchiveMapKitID() {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    #expect(VenueMapFile.line(for: venue, pick: nil) == "v1*n*c*s*mapkit=I1")
    #expect(VenueMapFile.line(for: venue, pick: .place(identifier: "I2")) == "v1*n*c*s*mapkit=I2")
    #expect(VenueMapFile.line(for: venue, pick: .noPlace) == "v1*n*c*s")
  }
}
