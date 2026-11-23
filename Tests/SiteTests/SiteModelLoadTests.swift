//
//  SiteModelLoadTests.swift
//  site
//
//  Created by Greg Bolsinga on 11/22/26.
//

import CoreLocation
import Foundation
import Synchronization
import Testing

@testable import Shared
@testable import SiteApp

@MainActor
struct SiteModelLoadTests {
  private struct LoadFailure: Error {}

  #if !os(tvOS)
    /// Counts what a load asked of the system.
    private final class Recorder: Sendable {
      private let counts = Mutex((wrote: 0, reloaded: 0, indexed: 0))
      var wrote: Int { counts.withLock { $0.wrote } }
      var reloaded: Int { counts.withLock { $0.reloaded } }
      var indexed: Int { counts.withLock { $0.indexed } }
      func didWrite() { counts.withLock { $0.wrote += 1 } }
      func didReload() { counts.withLock { $0.reloaded += 1 } }
      func didIndex() { counts.withLock { $0.indexed += 1 } }
    }
  #endif

  private struct NoLocation: LocationSource {
    let isAuthorizationDetermined = false
    func events() -> AsyncThrowingStream<LocationManager.Event, Error> {
      AsyncThrowingStream { $0.finish() }
    }
  }

  /// A model that asks nothing of the system, and on the platforms that have them, counts the asks.
  private struct Fixture {
    let model: SiteModel
    #if !os(tvOS)
      let recorder: Recorder
    #endif
  }

  private func makeVault(host: String = "www") async throws -> Vault {
    Vault(
      lookup: try await Lookup(
        bracket: try await Bracket(
          music: Music(
            albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date(),
            venues: []),
          timestamp: .now)),
      rootURL: URL(string: "https://\(host).example.com/")!)
  }

  private func makeFixture(
    load: @escaping @Sendable (String, Lookup.LoadPolicy) async throws -> Vault
  ) -> Fixture {
    let model = SiteModel(urlString: "https://www.example.com/")
    model.vaultProvider = VaultProvider(urlString: "https://www.example.com/", load: load)
    model.makeVaultModel = { vault, execute in
      VaultModel(
        vault, executeAsynchronousTasks: execute, locationSource: NoLocation(),
        notificationCenter: NotificationCenter())
    }
    #if os(tvOS)
      return Fixture(model: model)
    #else
      let recorder = Recorder()
      model.writeWidgetSnapshot = { _ in
        recorder.didWrite()
        return true
      }
      model.reloadWidgetTimelines = { recorder.didReload() }
      model.indexSpotlight = { _ in recorder.didIndex() }
      return Fixture(model: model, recorder: recorder)
    #endif
  }

  @Test func aFailedLoadSetsTheErrorAndMakesNoModel() async throws {
    let model = makeFixture { _, _ in throw LoadFailure() }.model

    await model.load(.initial)

    #expect(model.vaultModel == nil)
    #expect(model.error is LoadFailure)
  }

  @Test func theLoadThatStartedLastWinsWhateverOrderTheyFinishIn() async throws {
    let slow = try await makeVault(host: "slow")
    let fast = try await makeVault(host: "fast")
    let started = Gate()
    let release = Gate()
    let calls = Mutex(0)
    let model = makeFixture { _, _ in
      let call = calls.withLock {
        $0 += 1
        return $0
      }
      guard call == 1 else { return fast }
      await started.open()
      await release.wait()
      return slow
    }.model

    let first = Task { await model.load(.refresh) }
    await started.wait()
    await model.load(.errorRetry)
    await release.open()
    await first.value
    model.vaultModel?.cancelTasks()

    #expect(model.vaultModel?.vault.rootURL == fast.rootURL)
  }

  #if !os(tvOS)
    @Test func aLoadMakesTheModelPublishesTheWidgetAndIndexesSpotlight() async throws {
      let vault = try await makeVault()
      let fixture = makeFixture { _, _ in vault }

      await fixture.model.load(.initial)
      await fixture.model.widgetPublish?.value
      fixture.model.vaultModel?.cancelTasks()

      #expect(fixture.model.vaultModel?.vault.rootURL == vault.rootURL)
      #expect(fixture.model.error == nil)
      #expect(fixture.recorder.wrote == 1)
      #expect(fixture.recorder.reloaded == 1)
      #expect(fixture.recorder.indexed == 1)
    }

    @Test func aPreviewLoadLeavesTheSystemAlone() async throws {
      let vault = try await makeVault()
      let fixture = makeFixture { _, _ in vault }

      await fixture.model.load(.preview)

      #expect(fixture.model.vaultModel != nil)
      #expect(fixture.recorder.wrote == 0)
      #expect(fixture.recorder.reloaded == 0)
      #expect(fixture.recorder.indexed == 0)
    }

    @Test func onlyTheLoadThatWonIndexesSpotlight() async throws {
      let slow = try await makeVault(host: "slow")
      let fast = try await makeVault(host: "fast")
      let started = Gate()
      let release = Gate()
      let calls = Mutex(0)
      let fixture = makeFixture { _, _ in
        let call = calls.withLock {
          $0 += 1
          return $0
        }
        guard call == 1 else { return fast }
        await started.open()
        await release.wait()
        return slow
      }

      let first = Task { await fixture.model.load(.refresh) }
      await started.wait()
      await fixture.model.load(.errorRetry)
      await release.open()
      await first.value
      fixture.model.vaultModel?.cancelTasks()

      #expect(fixture.recorder.indexed == 1)
    }
  #endif
}
