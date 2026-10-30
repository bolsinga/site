//
//  CurrentCityTests.swift
//  site
//
//  Created by Greg Bolsinga on 10/29/26.
//

import CoreLocation
import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct CurrentCityTests {
  private let origin = CLLocation(latitude: 37.0, longitude: -122.0)
  private let far = CLLocation(latitude: 37.1, longitude: -122.0)  // ~11 km
  private let jump = CLLocation(latitude: 38.0, longitude: -122.0)  // ~111 km
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

  @Test func jumpGeocodesEvenSoon() {
    #expect(
      ReverseGeocodePolicy.shouldGeocode(
        last: attempt, location: jump, now: start.addingTimeInterval(5)))
  }

  @Test func nearAndLaterDoesNot() {
    #expect(
      !ReverseGeocodePolicy.shouldGeocode(
        last: attempt, location: near, now: start.addingTimeInterval(600)))
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

  // MARK: In-flight lookups

  private let denver = CLLocation(latitude: 39.74, longitude: -104.99)
  private let cupertino = CLLocation(latitude: 37.33, longitude: -122.03)

  /// Answers after a delay and, like a lookup that already had its answer, ignores cancellation.
  private struct DelayedResolver: CityResolver {
    let answers: [Double: (city: String, delay: Duration)]
    func city(for location: CLLocation) async throws -> String? {
      guard let answer = answers[location.coordinate.latitude] else { return nil }
      try? await Task.sleep(for: answer.delay)
      return answer.city
    }
  }

  @MainActor private func createModel(_ resolver: any CityResolver) async throws -> VaultModel {
    let vault = Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date(),
            venues: []),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
    return VaultModel(vault, executeAsynchronousTasks: false, cityResolver: resolver)
  }

  @MainActor @Test func locationResolvesCity() async throws {
    let model = try await createModel(
      DelayedResolver(answers: [denver.coordinate.latitude: ("Denver", .zero)]))
    model.handle(.location(denver))
    await model.cityTask?.value
    #expect(model.currentCity == "Denver")
  }

  @MainActor @Test func denialDropsAnInFlightCity() async throws {
    let model = try await createModel(
      DelayedResolver(answers: [denver.coordinate.latitude: ("Denver", .milliseconds(100))]))
    model.handle(.location(denver))
    let inFlight = try #require(model.cityTask)
    model.handle(.denied)
    await inFlight.value
    #expect(model.currentCity == nil)
    #expect(model.locationAuthorization == .denied)
  }

  @MainActor @Test func aNewerLocationReplacesAnInFlightCity() async throws {
    let model = try await createModel(
      DelayedResolver(answers: [
        denver.coordinate.latitude: ("Denver", .milliseconds(150)),
        cupertino.coordinate.latitude: ("Cupertino", .zero),
      ]))
    model.handle(.location(denver))
    let first = try #require(model.cityTask)
    model.handle(.location(cupertino))
    let second = try #require(model.cityTask)
    await second.value
    await first.value
    #expect(model.currentCity == "Cupertino")
  }

  @MainActor @Test func regrantingLocationGeocodesAgain() async throws {
    let model = try await createModel(
      DelayedResolver(answers: [denver.coordinate.latitude: ("Denver", .zero)]))
    model.handle(.location(denver))
    await model.cityTask?.value
    model.handle(.denied)
    #expect(model.currentCity == nil)
    model.handle(.location(denver))
    await model.cityTask?.value
    #expect(model.currentCity == "Denver")
  }
}
