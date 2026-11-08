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

  @Test func foundPlaceNeedsNoLookup() async throws {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    let item = try await Placemark.place(
      identifier: "I1", coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2)
    ).mapItem(for: venue)
    #expect(item.location.coordinate.latitude == 1)
    #expect(item.name == "n")
  }

  private let address = MapsAddress(street: "1 Main St", city: "c", cityAndState: "c, s")

  @Test func cachedAddressGivesWayToMapKitID() {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    let coordinate = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    #expect(!venue.canUseCached(.coordinate(coordinate, maps: address)))
    #expect(!venue.canUseCached(.identifier("I1")))
    #expect(!venue.canUseCached(.place(identifier: "I2", coordinate: coordinate, maps: address)))
    #expect(venue.canUseCached(.place(identifier: "I1", coordinate: coordinate, maps: address)))
  }

  @Test func cacheHoldsWithoutMapKitID() {
    let venue = Venue(id: "v1", location: Location(city: "c", state: "s"), name: "n")
    #expect(
      venue.canUseCached(
        .coordinate(CLLocationCoordinate2D(latitude: 1, longitude: 2), maps: address)))
  }

  @Test func placeCachedWithoutMapsAddressIsFoundAgain() {
    let coordinate = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    let venue = Venue(id: "v1", location: Location(city: "c", state: "s"), name: "n")
    #expect(!venue.canUseCached(.coordinate(coordinate)))
    let placed = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    #expect(!placed.canUseCached(.place(identifier: "I1", coordinate: coordinate)))
  }

  @Test func placemarkCachedBeforeAddressStillReads() throws {
    let json = Data(#"{"coordinate":{"_0":{"latitude":1,"longitude":2}}}"#.utf8)
    let placemark = try JSONDecoder().decode(Placemark.self, from: json)
    guard case .coordinate(let coordinate, let address) = placemark else {
      Issue.record("not a coordinate")
      return
    }
    #expect(coordinate.latitude == 1)
    #expect(address == nil)
  }

  @Test func placemarkCachedWithEarlierAddressIsFoundAgain() throws {
    let json = Data(
      #"{"coordinate":{"_0":{"latitude":1,"longitude":2},"address":{"lines":["c, s"],"city":"c"}}}"#
        .utf8)
    let placemark = try JSONDecoder().decode(Placemark.self, from: json)
    #expect(placemark.address == nil)
    let venue = Venue(id: "v1", location: Location(city: "c", state: "s"), name: "n")
    #expect(!venue.canUseCached(placemark))
  }

  @Test func mapsAddressIsSaved() throws {
    let placemark = Placemark.place(
      identifier: "I1", coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2),
      maps: address)
    let decoded = try JSONDecoder().decode(
      Placemark.self, from: JSONEncoder().encode(placemark))
    #expect(decoded.address == address)
  }

  /// An `Atlas` whose cache file holds a placemark for v1, geocoded from the venue as it is.
  private func atlas(caching placemark: Placemark, for venue: Venue, fileName: String) throws -> (
    Atlas<Venue>, ArchivePath
  ) {
    let id = try ArchivePath(raw: "v1")
    var cache = AtlasCache<Venue>(fileName: fileName)
    cache.add(id, value: placemark, source: venue.geocodeSource)
    return (Atlas(cache: cache), id)
  }

  private func removeCache(fileName: String) {
    _ = try? [ArchivePath: AtlasCache<Venue>.Value].read(fileName: fileName, deleteFile: true)
  }

  @Test func atlasUsesCachedPlaceForMapKitID() async throws {
    let fileName = "atlas-test-\(UUID().uuidString).json"
    defer { removeCache(fileName: fileName) }
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    let (atlas, id) = try atlas(
      caching: .place(
        identifier: "I1", coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2),
        maps: address),
      for: venue, fileName: fileName)

    guard case .place(let identifier, let coordinate, _) = try await atlas.geocode(venue, id: id)
    else {
      Issue.record("not the cached place")
      return
    }
    #expect(identifier == "I1")
    #expect(coordinate.latitude == 1)
  }

  @Test func atlasKeepsCachedAddressWithoutMapKitID() async throws {
    let fileName = "atlas-test-\(UUID().uuidString).json"
    defer { removeCache(fileName: fileName) }
    let venue = Venue(id: "v1", location: Location(city: "c", state: "s"), name: "n")
    let (atlas, id) = try atlas(
      caching: .coordinate(CLLocationCoordinate2D(latitude: 1, longitude: 2), maps: address),
      for: venue, fileName: fileName)

    guard case .coordinate(let coordinate, _) = try await atlas.geocode(venue, id: id) else {
      Issue.record("not the cached address")
      return
    }
    #expect(coordinate.latitude == 1)
  }

  @Test func unpickedVenueKeepsArchiveMapKitID() {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "I1")
    #expect(VenueMapFile.line(for: venue, pick: nil) == "v1*n*c*s*mapkit=I1")
    #expect(VenueMapFile.line(for: venue, pick: .place(identifier: "I2")) == "v1*n*c*s*mapkit=I2")
    #expect(VenueMapFile.line(for: venue, pick: .noPlace) == "v1*n*c*s")
  }
}
