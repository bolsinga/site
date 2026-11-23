//
//  SiteModelLoadTests.swift
//  site
//
//  Created by Greg Bolsinga on 11/22/26.
//

#if !os(tvOS)
  import CoreLocation
  import Foundation
  import Synchronization
  import Testing

  @testable import Shared
  @testable import SiteApp

  @MainActor
  struct SiteModelLoadTests {
    private struct LoadFailure: Error {}

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

    private struct NoLocation: LocationSource {
      let isAuthorizationDetermined = false
      func events() -> AsyncThrowingStream<LocationManager.Event, Error> {
        AsyncThrowingStream { $0.finish() }
      }
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

    private func makeModel(
      _ recorder: Recorder,
      load: @escaping @Sendable (String, Lookup.LoadPolicy) async throws -> Vault
    ) -> SiteModel {
      let model = SiteModel(urlString: "https://www.example.com/")
      model.vaultProvider = VaultProvider(urlString: "https://www.example.com/", load: load)
      model.writeWidgetSnapshot = { _ in
        recorder.didWrite()
        return true
      }
      model.reloadWidgetTimelines = { recorder.didReload() }
      model.indexSpotlight = { _ in recorder.didIndex() }
      model.makeVaultModel = { vault, execute in
        VaultModel(
          vault, executeAsynchronousTasks: execute, locationSource: NoLocation(),
          notificationCenter: NotificationCenter())
      }
      return model
    }

    @Test func aLoadMakesTheModelPublishesTheWidgetAndIndexesSpotlight() async throws {
      let vault = try await makeVault()
      let recorder = Recorder()
      let model = makeModel(recorder) { _, _ in vault }

      await model.load(.initial)
      await model.widgetPublish?.value
      model.vaultModel?.cancelTasks()

      #expect(model.vaultModel?.vault.rootURL == vault.rootURL)
      #expect(model.error == nil)
      #expect(recorder.wrote == 1)
      #expect(recorder.reloaded == 1)
      #expect(recorder.indexed == 1)
    }

    @Test func aPreviewLoadLeavesTheSystemAlone() async throws {
      let vault = try await makeVault()
      let recorder = Recorder()
      let model = makeModel(recorder) { _, _ in vault }

      await model.load(.preview)

      #expect(model.vaultModel != nil)
      #expect(recorder.wrote == 0)
      #expect(recorder.reloaded == 0)
      #expect(recorder.indexed == 0)
    }

    @Test func aFailedLoadSetsTheErrorAndMakesNoModel() async throws {
      let recorder = Recorder()
      let model = makeModel(recorder) { _, _ in throw LoadFailure() }

      await model.load(.initial)

      #expect(model.vaultModel == nil)
      #expect(model.error is LoadFailure)
      #expect(recorder.indexed == 0)
    }

    @Test func theLoadThatStartedLastWinsWhateverOrderTheyFinishIn() async throws {
      let slow = try await makeVault(host: "slow")
      let fast = try await makeVault(host: "fast")
      let started = Gate()
      let release = Gate()
      let calls = Mutex(0)
      let recorder = Recorder()
      let model = makeModel(recorder) { _, _ in
        let call = calls.withLock {
          $0 += 1
          return $0
        }
        guard call == 1 else { return fast }
        await started.open()
        await release.wait()
        return slow
      }

      let first = Task { await model.load(.refresh) }
      await started.wait()
      await model.load(.errorRetry)
      await release.open()
      await first.value
      model.vaultModel?.cancelTasks()

      #expect(model.vaultModel?.vault.rootURL == fast.rootURL)
      #expect(recorder.indexed == 1)
    }
  }
#endif
