//
//  VaultModelServicesTests.swift
//  site
//
//  Created by Greg Bolsinga on 11/22/26.
//

import CoreLocation
import Foundation
import Synchronization
import Testing

@testable import Shared
@testable import SiteCore

@MainActor
struct VaultModelServicesTests {
  private let denver = CLLocation(latitude: 39.74, longitude: -104.99)

  /// Reports what the test sends, and counts how often it was asked to listen.
  private final class FakeLocationSource: LocationSource {
    let isAuthorizationDetermined: Bool
    private let asks = Mutex(0)
    private let stream: AsyncThrowingStream<LocationManager.Event, Error>
    private let continuation: AsyncThrowingStream<LocationManager.Event, Error>.Continuation

    init(determined: Bool) {
      isAuthorizationDetermined = determined
      (stream, continuation) = AsyncThrowingStream.makeStream()
    }

    var asked: Int { asks.withLock { $0 } }

    func events() -> AsyncThrowingStream<LocationManager.Event, Error> {
      asks.withLock { $0 += 1 }
      return stream
    }

    func send(_ event: LocationManager.Event) { continuation.yield(event) }
    func finish() { continuation.finish() }
  }

  /// Answers with one city, and opens its gate when asked.
  private struct FixedResolver: CityResolver {
    let name: String
    let asked = Gate()
    func city(for location: CLLocation) async throws -> String? {
      await asked.open()
      return name
    }
  }

  private func makeVault() async throws -> Vault {
    Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date(),
            venues: []),
          timestamp: .now)),
      rootURL: URL(string: "https://www.example.com/")!)
  }

  private func makeModel(
    _ source: FakeLocationSource, resolver: FixedResolver = FixedResolver(name: "Denver"),
    now: @escaping @Sendable () -> Date = { .now }
  ) async throws -> VaultModel {
    VaultModel(
      try await makeVault(), executeAsynchronousTasks: true,
      cityResolver: resolver, locationSource: source, now: now,
      notificationCenter: NotificationCenter())
  }

  @Test func aPromptNotYetAnsweredIsNotListenedForAtLaunch() async throws {
    let source = FakeLocationSource(determined: false)
    let model = try await makeModel(source)
    defer { model.cancelTasks() }

    #expect(model.locationTask == nil)
    #expect(source.asked == 0)
    #expect(model.locationAuthorization == .notDetermined)
  }

  @Test func anAnswerAlreadyGivenIsListenedForAtLaunch() async throws {
    let source = FakeLocationSource(determined: true)
    let model = try await makeModel(source)
    defer { model.cancelTasks() }

    #expect(model.locationTask != nil)
  }

  @Test func turningTheFilterOnStartsListeningOnce() async throws {
    let source = FakeLocationSource(determined: false)
    let model = try await makeModel(source)
    defer { model.cancelTasks() }

    model.startLocationMonitoring()
    let first = model.locationTask
    model.startLocationMonitoring()

    #expect(first != nil)
    #expect(model.locationTask == first)
  }

  @Test func aLocationFromTheSourceResolvesTheCity() async throws {
    let source = FakeLocationSource(determined: false)
    let resolver = FixedResolver(name: "Denver")
    let model = try await makeModel(source, resolver: resolver)
    defer { model.cancelTasks() }

    model.startLocationMonitoring()
    source.send(.location(denver))
    await resolver.asked.wait()
    await model.cityTask?.value

    #expect(model.locationAuthorization == .allowed)
    #expect(model.currentCity == "Denver")
  }

  @Test func aDenialThenAllowingAgainClearsTheDenialWithoutACity() async throws {
    let source = FakeLocationSource(determined: false)
    let model = try await makeModel(source)
    defer { model.cancelTasks() }

    model.startLocationMonitoring()
    source.send(.denied)
    source.send(.allowed)
    source.finish()
    await model.locationTask?.value

    #expect(model.locationAuthorization == .allowed)
    #expect(model.currentCity == nil)
  }

  @Test func todayFollowsTheClockGiven() async throws {
    let january = try #require(
      Calendar.archive.date(from: DateComponents(year: 2024, month: 1, day: 15, hour: 12)))
    let march = try #require(
      Calendar.archive.date(from: DateComponents(year: 2024, month: 3, day: 1, hour: 12)))
    let clock = Mutex(january)
    let model = try await makeModel(
      FakeLocationSource(determined: false), now: { clock.withLock { $0 } })
    defer { model.cancelTasks() }

    #expect(model.todayDayOfLeapYear == january.dayOfLeapYear)

    clock.withLock { $0 = march }
    model.refreshToday()

    #expect(model.todayDayOfLeapYear == march.dayOfLeapYear)
    #expect(march.dayOfLeapYear != january.dayOfLeapYear)
  }
}
