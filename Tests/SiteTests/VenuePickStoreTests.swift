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
    guard case .coordinate(let coordinate, _) = pick.placemark else {
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

  @Test func storeWithoutFileOnlyTracksEdits() {
    let store = VenuePickStore()
    #expect(!store.isEdited)

    store["v1"] = .noPlace
    #expect(store.isEdited)
    #expect(store.picks == ["v1": .noPlace])

    store.markSaved()
    #expect(!store.isEdited)
    #expect(store.picks == ["v1": .noPlace])

    store["v1"] = nil
    #expect(store.isEdited)
  }

  @Test func removeAllIsNotAnEdit() {
    let store = VenuePickStore()
    store["v1"] = .noPlace
    store.removeAll()
    #expect(!store.isEdited)
    #expect(store.picks.isEmpty)
  }
}

struct VenuePlacesCacheTests {
  private func temporaryDirectory() throws -> URL {
    let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }

  @Test func cacheFileIsInTheCachesDirectory() throws {
    let caches = try temporaryDirectory()
    let legacy = try temporaryDirectory()
    let url = VenuePlacesCache.fileURL(named: "venue-checks.json", caches: caches, legacy: legacy)
    #expect(url == caches.appending(path: "venue-checks.json"))
  }

  @Test func fileKeptElsewhereBeforeIsRemoved() throws {
    let caches = try temporaryDirectory()
    let legacy = try temporaryDirectory()
    let old = legacy.appending(path: "venue-checks.json")
    try Data("{}".utf8).write(to: old)

    _ = VenuePlacesCache.fileURL(named: "venue-checks.json", caches: caches, legacy: legacy)
    #expect(!FileManager.default.fileExists(atPath: old.path(percentEncoded: false)))
  }

  @Test func nothingKeptElsewhereIsFine() throws {
    let caches = try temporaryDirectory()
    let legacy = try temporaryDirectory()
    _ = VenuePlacesCache.fileURL(named: "venue-checks.json", caches: caches, legacy: legacy)
  }
}
