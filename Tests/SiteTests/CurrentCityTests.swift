//
//  CurrentCityTests.swift
//  site
//
//  Created by Greg Bolsinga on 10/29/26.
//

import CoreLocation
import Foundation
import Testing

@testable import SiteApp

struct CurrentCityTests {
  private let origin = CLLocation(latitude: 37.0, longitude: -122.0)
  private let far = CLLocation(latitude: 37.1, longitude: -122.0)  // ~11 km
  private let near = CLLocation(latitude: 37.001, longitude: -122.0)  // ~111 m
  private let start = Date(timeIntervalSince1970: 1_000_000)

  private var attempt: ReverseGeocodePolicy.Attempt {
    .init(location: origin, date: start)
  }

  @Test func firstLocationGeocodes() {
    #expect(ReverseGeocodePolicy.shouldGeocode(last: nil, location: origin, now: start))
  }

  @Test func farAndLaterGeocodes() {
    #expect(
      ReverseGeocodePolicy.shouldGeocode(
        last: attempt, location: far, now: start.addingTimeInterval(60)))
  }

  @Test func farButSoonDoesNot() {
    #expect(
      !ReverseGeocodePolicy.shouldGeocode(
        last: attempt, location: far, now: start.addingTimeInterval(59)))
  }

  @Test func nearAndLaterDoesNot() {
    #expect(
      !ReverseGeocodePolicy.shouldGeocode(
        last: attempt, location: near, now: start.addingTimeInterval(600)))
  }

  @Test func suggestsWhenSearchIsEmpty() {
    #expect(currentCitySuggestion(current: "Oakland", searchText: "") == "Oakland")
    #expect(currentCitySuggestion(current: " Oakland ", searchText: "  ") == "Oakland")
  }

  @Test func noSuggestionWhileTyping() {
    #expect(currentCitySuggestion(current: "Oakland", searchText: "Sea") == nil)
    #expect(currentCitySuggestion(current: "Oakland", searchText: "Oakland") == nil)
  }

  @Test func noSuggestionWithoutCity() {
    #expect(currentCitySuggestion(current: nil, searchText: "") == nil)
    #expect(currentCitySuggestion(current: " ", searchText: "") == nil)
  }

  private struct StubResolver: CityResolver {
    struct Failure: Error {}
    let result: Result<String?, Failure>
    func city(for location: CLLocation) async throws -> String? { try result.get() }
  }

  @Test func resolverReturnsCity() async throws {
    let resolver: any CityResolver = StubResolver(result: .success("Oakland"))
    #expect(try await resolver.city(for: origin) == "Oakland")
  }

  @Test func resolverReturnsNil() async throws {
    let resolver: any CityResolver = StubResolver(result: .success(nil))
    #expect(try await resolver.city(for: origin) == nil)
  }

  @Test func resolverThrows() async {
    let resolver: any CityResolver = StubResolver(result: .failure(.init()))
    await #expect(throws: StubResolver.Failure.self) {
      try await resolver.city(for: origin)
    }
  }
}
