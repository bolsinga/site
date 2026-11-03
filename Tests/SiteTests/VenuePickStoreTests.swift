//
//  VenuePickStoreTests.swift
//
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Foundation
import Testing

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
}
