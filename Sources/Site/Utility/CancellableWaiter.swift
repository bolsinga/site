//
//  CancellableWaiter.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Synchronization

/// Waits for one value to be delivered from outside of Swift concurrency, and gives up when the
/// waiting task is cancelled. A plain `withCheckedContinuation` would wait for the value regardless.
final class CancellableWaiter<Value: Sendable>: Sendable {
  private enum State {
    case idle
    case waiting(CheckedContinuation<Value?, Never>)
    case delivered(Value)
    case cancelled
  }

  private let state = Mutex<State>(.idle)

  /// Returns the delivered value, or `nil` if the task was cancelled before one arrived.
  /// A value delivered before this is called is still returned.
  func wait() async -> Value? {
    await withTaskCancellationHandler {
      await withCheckedContinuation { continuation in
        let immediate: Value?? = state.withLock { state in
          switch state {
          case .idle:
            state = .waiting(continuation)
            return nil
          case .delivered(let value):
            return .some(value)
          case .cancelled:
            return .some(nil)
          case .waiting:
            preconditionFailure("CancellableWaiter waited on twice")
          }
        }
        if let immediate {
          continuation.resume(returning: immediate)
        }
      }
    } onCancel: {
      let continuation: CheckedContinuation<Value?, Never>? = state.withLock { state in
        defer { state = .cancelled }
        guard case .waiting(let continuation) = state else { return nil }
        return continuation
      }
      continuation?.resume(returning: nil)
    }
  }

  /// Delivers the value to the waiter. Ignored if the waiter was cancelled or already delivered to.
  func deliver(_ value: Value) {
    let continuation: CheckedContinuation<Value?, Never>? = state.withLock { state in
      switch state {
      case .idle:
        state = .delivered(value)
        return nil
      case .waiting(let continuation):
        state = .delivered(value)
        return continuation
      case .delivered, .cancelled:
        return nil
      }
    }
    continuation?.resume(returning: value)
  }
}
