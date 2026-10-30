//
//  CityFilterTests.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/29/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct CityFilterTests {
  // MARK: Matching

  @Test func matchesIgnoringCaseDiacriticsAndWhitespace() {
    #expect(cityMatches("Zürich", filter: "zurich"))
    #expect(cityMatches("Denver", filter: "  DENVER "))
    #expect(cityMatches("San Francisco", filter: "francisco"))
  }

  @Test func doesNotMatchOtherOrBlank() {
    #expect(!cityMatches("Denver", filter: "Chicago"))
    #expect(!cityMatches("Denver", filter: "  "))
    #expect(!cityMatches(nil, filter: "Denver"))
  }

  // MARK: Effective city

  @Test func defaultsToCurrentCity() {
    let model = NearbyModel()
    #expect(model.effectiveCity(current: "Denver") == "Denver")
    #expect(model.effectiveCity(current: " Denver ") == "Denver")
  }

  @Test func typedCityWinsOverCurrent() {
    let model = NearbyModel()
    model.cityName = " Chicago "
    #expect(model.effectiveCity(current: "Denver") == "Chicago")
    #expect(model.effectiveCity(current: nil) == "Chicago")
  }

  @Test func clearingTypedCityReturnsToCurrent() {
    let model = NearbyModel()
    model.cityName = "Chicago"
    model.cityName = "  "
    #expect(model.cityName.isEmpty)
    #expect(model.effectiveCity(current: "Denver") == "Denver")
  }

  @Test func noCityWithoutCurrentOrTyped() {
    let model = NearbyModel()
    #expect(model.effectiveCity(current: nil) == nil)
    #expect(model.effectiveCity(current: "  ") == nil)
  }

  // MARK: Mode

  @Test func toggleUsesSelectedMode() {
    let model = NearbyModel()
    model.isOn.toggle()
    #expect(model.locationFilter == .nearby)
    model.mode = .city
    #expect(model.locationFilter == .city)
    model.isOn.toggle()
    #expect(model.locationFilter == .none)
    model.isOn.toggle()
    #expect(model.locationFilter == .city)
  }

  @Test func modeChangeWhileOffStaysOff() {
    let model = NearbyModel()
    model.mode = .city
    #expect(model.locationFilter == .none)
    #expect(!model.isOn)
  }

  // MARK: State JSON

  @Test func oldJSONStillDecodes() throws {
    let nearby = try #require(NearbyModel.State(jsonString: #"{"locationFilter":1}"#))
    #expect(nearby.locationFilter == .nearby)
    #expect(nearby.mode == .nearby)
    #expect(nearby.cityName == nil)
    let off = try #require(NearbyModel.State(jsonString: #"{"locationFilter":0}"#))
    #expect(off.locationFilter == .none)
    #expect(off.mode == .nearby)
  }

  @Test func newJSONRoundTrips() throws {
    let state = NearbyModel.State(locationFilter: .city, mode: .city, cityName: "Chicago")
    let decoded = try #require(NearbyModel.State(jsonString: state.jsonString))
    #expect(decoded == state)
    let off = NearbyModel.State(locationFilter: .none, mode: .city, cityName: nil)
    #expect(try #require(NearbyModel.State(jsonString: off.jsonString)) == off)
  }

  @Test func modelRoundTripsThroughRawValue() throws {
    let model = NearbyModel()
    model.mode = .city
    model.cityName = "Chicago"
    model.isOn = true
    let restored = try #require(NearbyModel(rawValue: model.rawValue))
    #expect(restored.locationFilter == .city)
    #expect(restored.cityName == "Chicago")
  }

  // MARK: Venues

  private let chicago = Venue(
    id: "v0", location: Location(city: "Chicago", state: "IL"), name: "V0")
  private let denver = Venue(
    id: "v1", location: Location(city: "Denver", state: "CO"), name: "V1")
  private let artist = Artist(id: "ar0", name: "Pavement")

  @MainActor private func createModel() async throws -> VaultModel {
    let shows = [
      Show(
        artists: [artist.id], date: PartialDate(year: 1996, month: 5, day: 1), id: "sh0",
        venue: chicago.id),
      Show(
        artists: [artist.id], date: PartialDate(year: 1997, month: 5, day: 1), id: "sh1",
        venue: denver.id),
    ]
    let vault = Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [artist], relations: [], shows: shows, songs: [],
            timestamp: Date(), venues: [chicago, denver]),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
    return VaultModel(vault, executeAsynchronousTasks: false)
  }

  @MainActor @Test func venueIDsFilterByCity() async throws {
    let model = try await createModel()
    #expect(model.venueIDsInCity("denver").count == 1)
    #expect(model.venueIDsInCity("Chicago").count == 1)
    #expect(model.venueIDsInCity("Paris").isEmpty)
    #expect(model.venueIDsInCity(nil).isEmpty)
  }

  @MainActor @Test func cityModeFiltersVenuesArtistsAndShows() async throws {
    let model = try await createModel()
    let filter = NearbyModel()
    filter.mode = .city
    filter.cityName = "Chicago"
    filter.isOn = true
    #expect(model.nearbyVenues(filter, distanceThreshold: 100).count == 1)
    #expect(model.nearbyArtists(filter, distanceThreshold: 100).count == 1)
    #expect(model.filteredStatisticsData(filter, distanceThreshold: 100).showsCount == 1)
    filter.cityName = "Paris"
    #expect(model.nearbyVenues(filter, distanceThreshold: 100).isEmpty)
    #expect(model.nearbyArtists(filter, distanceThreshold: 100).isEmpty)
    #expect(model.filteredDecadesMap(filter, distanceThreshold: 100).isEmpty)
    filter.isOn = false
    #expect(model.nearbyVenues(filter, distanceThreshold: 100).count == 2)
  }
}
