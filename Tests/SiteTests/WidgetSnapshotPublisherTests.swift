//
//  WidgetSnapshotPublisherTests.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

#if !os(tvOS)
  import Foundation
  import Synchronization
  import Testing

  @testable import Shared
  @testable import SiteApp

  @MainActor
  struct WidgetSnapshotPublisherTests {
    struct BuildFailure: Error {}

    nonisolated static func snapshot(generated: TimeInterval = 0) -> ShowsTodaySnapshot {
      ShowsTodaySnapshot(generated: Date(timeIntervalSince1970: generated), days: [:])
    }

    @Test func aPublishWritesAndReloads() async {
      let model = SiteModel(urlString: "")
      let written = Mutex<[ShowsTodaySnapshot]>([])
      let reloads = Mutex(0)

      await model.publishWidgetSnapshot(
        build: { Self.snapshot() },
        write: { snapshot in
          written.withLock { $0.append(snapshot) }
          return true
        },
        reload: { reloads.withLock { $0 += 1 } }
      ).value

      #expect(written.withLock { $0.count } == 1)
      #expect(reloads.withLock { $0 } == 1)
    }

    @Test func anUnchangedSnapshotIsNotReloaded() async {
      let model = SiteModel(urlString: "")
      let reloads = Mutex(0)

      await model.publishWidgetSnapshot(
        build: { Self.snapshot() },
        write: { _ in false },
        reload: { reloads.withLock { $0 += 1 } }
      ).value

      #expect(reloads.withLock { $0 } == 0)
    }

    @Test func aFailedBuildWritesNothing() async {
      let model = SiteModel(urlString: "")
      let writes = Mutex(0)

      await model.publishWidgetSnapshot(
        build: { throw BuildFailure() },
        write: { _ in
          writes.withLock { $0 += 1 }
          return true
        },
        reload: {}
      ).value

      #expect(writes.withLock { $0 } == 0)
    }

    @Test func aNewerPublishSupersedesOneStillBuilding() async {
      let model = SiteModel(urlString: "")
      let written = Mutex<[TimeInterval]>([])
      let release = DispatchSemaphore(value: 0)
      let started = Mutex(false)

      let older = model.publishWidgetSnapshot(
        build: {
          started.withLock { $0 = true }
          release.wait()
          return Self.snapshot(generated: 1)
        },
        write: { snapshot in
          written.withLock { $0.append(snapshot.generated.timeIntervalSince1970) }
          return true
        },
        reload: {})

      // Wait until the older one is building, so the newer one starts after it.
      while !started.withLock({ $0 }) { await Task.yield() }

      let newer = model.publishWidgetSnapshot(
        build: { Self.snapshot(generated: 2) },
        write: { snapshot in
          written.withLock { $0.append(snapshot.generated.timeIntervalSince1970) }
          return true
        },
        reload: {})

      // The older one finishes building after it was cancelled, and must not write.
      release.signal()
      await older.value
      await newer.value

      #expect(written.withLock { $0 } == [2])
    }
  }
#endif
