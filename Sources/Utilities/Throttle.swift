//
//  Throttle.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/11/25.
//

import Foundation
import os

extension Logger {
  fileprivate static let throttle = Logger(category: "throttle")
}

actor Throttle<T> {
  enum Control {
    /// Client requires the throttle to be paused
    case pauseEntry

    /// An error occurred that is not recoverable. Keep going..
    case nonRecoverableError

    /// Successful batch
    case success(T)
  }

  /// The size of the batch to be throttled.
  let batchSize: Int

  /// Time to wait until the next batch is processed.
  let timeUntilReset: Duration

  /// Current count of batched items processed behind the throttle.
  var count: Int

  /// Current time to wait until for the next batch through the throttle.
  var waitUntil: ContinuousClock.Instant

  init(batchSize: Int, timeUntilReset: Duration) {
    self.batchSize = batchSize
    self.timeUntilReset = timeUntilReset
    self.count = 0
    self.waitUntil = .now + timeUntilReset
  }

  private func reset() {
    Logger.throttle.log("reset")
    waitUntil = .now + timeUntilReset
    count = 0
  }

  private func idleAndReset() async throws {
    Logger.throttle.log("idleAndReset")
    try await ContinuousClock().sleep(until: waitUntil)
    reset()
  }

  func perform(_ action: @escaping () async throws -> Control) async throws -> T? {
    Logger.throttle.log("start")
    defer {
      Logger.throttle.log("end")
    }

    if ContinuousClock.now.duration(to: waitUntil) <= .seconds(0) {
      // wait time expired
      Logger.throttle.log("wait expired")
      reset()
    } else if count != 0, count % batchSize == 0 {
      // hit max batch size
      Logger.throttle.log("reached batchSize")
      try await idleAndReset()
    }

    repeat {
      do {
        let control = try await action()
        count += 1

        switch control {
        case .pauseEntry:
          try await idleAndReset()
        case .nonRecoverableError:
          return nil
        case .success(let result):
          return result
        }
      } catch {
        Logger.throttle.error("unknown error: \(error.localizedDescription, privacy: .public)")
        throw error
      }
    } while true
  }
}
