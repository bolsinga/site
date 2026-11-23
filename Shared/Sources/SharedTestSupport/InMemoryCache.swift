//
//  InMemoryCache.swift
//  SiteApp
//

import Foundation
import Shared
import Synchronization

/// A `CacheCodable` that keeps its files in memory and records what was asked of it. Values are
/// encoded and decoded as JSON, as the real cache does, so a round trip checks `Codable` too.
public final class InMemoryCache: CacheCodable {
  public struct Failure: Error {}

  private struct State {
    var files = [String: Data]()
    var reads = [String]()
    var saves = [String]()
    var removals = [String]()
    var failsSaves = false
  }

  private let state = Mutex(State())

  /// Saves throw, and keep nothing.
  public init() {}

  public func failSaves() {
    state.withLock { $0.failsSaves = true }
  }

  /// A file that is already there, as if saved before.
  public func put<T: Encodable>(_ value: T, fileName: String) throws {
    let data = try Self.encoder.encode(value)
    state.withLock { $0.files[fileName] = data }
  }

  public func contains(fileName: String) -> Bool { state.withLock { $0.files[fileName] != nil } }
  public var reads: [String] { state.withLock { $0.reads } }
  public var saves: [String] { state.withLock { $0.saves } }
  public var removals: [String] { state.withLock { $0.removals } }

  private static var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }

  public func readCache<T: Decodable>(fileName: String, deleteFile: Bool) throws -> T {
    let data = try state.withLock { state in
      state.reads.append(fileName)
      guard let data = state.files[fileName] else { throw CocoaError(.fileReadNoSuchFile) }
      if deleteFile { state.files[fileName] = nil }
      return data
    }
    return try data.fromJSON()
  }

  public func saveCache<T: Encodable>(cacheData: T, fileName: String) throws {
    let data = try Self.encoder.encode(cacheData)
    try state.withLock { state in
      state.saves.append(fileName)
      guard !state.failsSaves else { throw Failure() }
      state.files[fileName] = data
    }
  }

  public func removeCache(fileName: String) {
    state.withLock { state in
      state.removals.append(fileName)
      state.files[fileName] = nil
    }
  }
}
