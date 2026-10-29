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

  @Test func seedsWhenEmptyAndNotOffered() {
    #expect(defaultCity(current: "Oakland", typed: "", alreadySeeded: false) == "Oakland")
    #expect(defaultCity(current: "Oakland", typed: "  ", alreadySeeded: false) == "Oakland")
  }

  @Test func doesNotOverwriteTyped() {
    #expect(defaultCity(current: "Oakland", typed: "Sea", alreadySeeded: false) == nil)
  }

  @Test func doesNotReseedAfterOffered() {
    #expect(defaultCity(current: "Oakland", typed: "", alreadySeeded: true) == nil)
  }

  @Test func noCityNoSeed() {
    #expect(defaultCity(current: nil, typed: "", alreadySeeded: false) == nil)
    #expect(defaultCity(current: " ", typed: "", alreadySeeded: false) == nil)
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
