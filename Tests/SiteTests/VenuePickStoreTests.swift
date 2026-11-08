//
//  VenuePickStoreTests.swift
//
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

@MainActor
struct VenuePickStoreTests {
  private func temporaryFileURL() -> URL {
    URL.temporaryDirectory.appending(path: "\(UUID().uuidString)/venue-places.json")
  }

  @Test(arguments: [
    VenuePick.place(identifier: "I1234"), .place(identifier: "I5678", address: "1 Main St"),
    .coordinate(latitude: 37.5, longitude: -122.25), .noPlace,
  ])
  func pickRoundTrips(pick: VenuePick) throws {
    let data = try JSONEncoder().encode(pick)
    #expect(try JSONDecoder().decode(VenuePick.self, from: data) == pick)
  }

  @Test func status() {
    #expect(VenuePickStatus(nil) == .unpicked)
    #expect(VenuePickStatus(.place(identifier: "I1")) == .picked)
    #expect(VenuePickStatus(.coordinate(latitude: 0, longitude: 0)) == .picked)
    #expect(VenuePickStatus(.noPlace) == .noPlace)
  }

  @Test func placePickIsAnIdentifierPlacemark() {
    guard case .identifier(let identifier) = VenuePick.place(identifier: "I1").placemark else {
      Issue.record("not an identifier")
      return
    }
    #expect(identifier == "I1")
  }

  @Test func pinPickIsACoordinatePlacemark() {
    let pick = VenuePick.coordinate(latitude: 37.5, longitude: -122.25)
    guard case .coordinate(let coordinate) = pick.placemark else {
      Issue.record("not a coordinate")
      return
    }
    #expect(coordinate.latitude == 37.5)
    #expect(coordinate.longitude == -122.25)
  }

  @Test func noPlacePickHasNoPlacemark() {
    #expect(VenuePick.noPlace.placemark == nil)
  }

  @Test func savedPicksAreReadBack() {
    let fileURL = temporaryFileURL()
    let store = VenuePickStore(fileURL: fileURL)
    store["v1"] = .place(identifier: "I1")
    store["v2"] = .noPlace
    store["v3"] = .coordinate(latitude: 1, longitude: 2)
    store["v3"] = nil

    let reread = VenuePickStore(fileURL: fileURL)
    #expect(reread.readError == nil)
    #expect(reread.picks == ["v1": .place(identifier: "I1"), "v2": .noPlace])
  }

  @Test func missingFileIsEmpty() {
    let store = VenuePickStore(fileURL: temporaryFileURL())
    #expect(store.picks.isEmpty)
    #expect(store.readError == nil)
  }

  @Test func unreadableFileIsNotOverwritten() throws {
    let fileURL = temporaryFileURL()
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data("not json".utf8).write(to: fileURL)

    let store = VenuePickStore(fileURL: fileURL)
    #expect(store.readError != nil)
    store["v1"] = .noPlace
    #expect(try String(contentsOf: fileURL, encoding: .utf8) == "not json")
  }

  @Test func removeAllDeletesPicksAndFile() {
    let fileURL = temporaryFileURL()
    let store = VenuePickStore(fileURL: fileURL)
    store["v1"] = .place(identifier: "I1")

    store.removeAll()
    #expect(store.picks.isEmpty)
    #expect(!FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)))
    #expect(VenuePickStore(fileURL: fileURL).picks.isEmpty)
  }

  @Test func removeAllRecoversFromUnreadableFile() throws {
    let fileURL = temporaryFileURL()
    try FileManager.default.createDirectory(
      at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data("not json".utf8).write(to: fileURL)
    let store = VenuePickStore(fileURL: fileURL)

    store.removeAll()
    #expect(store.readError == nil)
    store["v1"] = .noPlace
    #expect(VenuePickStore(fileURL: fileURL).picks == ["v1": .noPlace])
  }

  @Test func placeIdentifierIsPickedOrArchived() {
    let venue = Venue(
      id: "v1", location: Location(city: "c", state: "s"), name: "n", mapKitID: "IArchive")
    #expect(venue.placeIdentifier(pick: nil) == "IArchive")
    #expect(venue.placeIdentifier(pick: .place(identifier: "IPicked")) == "IPicked")
    #expect(venue.placeIdentifier(pick: .noPlace) == nil)
    #expect(venue.placeIdentifier(pick: .coordinate(latitude: 1, longitude: 2)) == nil)
    let unplaced = Venue(id: "v2", location: Location(city: "c", state: "s"), name: "n")
    #expect(unplaced.placeIdentifier(pick: nil) == nil)
  }

  @Test func removeAllWithoutFile() {
    let store = VenuePickStore(fileURL: temporaryFileURL())
    store.removeAll()
    #expect(store.picks.isEmpty)
    #expect(store.readError == nil)
  }
}
