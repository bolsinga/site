//
//  AtlasCache.swift
//
//
//  Created by Greg Bolsinga on 9/22/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let atlasCache = Logger(category: "atlasCache")
}

private let expirationOffset = 60.0 * 60.0 * 24.0 * 30.0 * 6.0  // Six months
private let ExpirationStaggerDuration = 60.0 * 60.0 * 6.0  // Quarter day

actor AtlasCache<T: AtlasGeocodable> {
  struct Value: Codable {
    var placemark: T.Place
    let expirationDate: Date
  }

  private let fileName: String

  private var staggerOffset = 0.0
  private var cache: [T: Value] = [:]

  internal init(fileName: String = "atlas.json") {
    self.fileName = fileName

    do {
      let diskCache = try [T: Value].read(fileName: fileName)
      let now = Date.now
      self.cache = diskCache.filter { $0.value.expirationDate >= now }  // Include those whose expiration date has not passed .now

      if self.cache.count != diskCache.count {
        Logger.atlasCache.log("removing expired items")
        try self.cache.save(fileName: fileName)  // Some expired, so re-write the file.
      }
    } catch {
      Logger.atlasCache.error("Cache Read Error: \(error, privacy: .public)")
      self.cache = [:]
    }
  }

  func get(_ item: T) -> T.Place? { self[item] }

  func add(_ item: T, value: T.Place) { self[item] = value }

  private subscript(index: T) -> T.Place? {
    get {
      cache[index]?.placemark
    }
    set(newValue) {
      if let newValue {
        cache[index] = Value(
          placemark: newValue,
          expirationDate: .now + expirationOffset + staggerOffset)

        // This allows batch geocodes to be "staggered" in their expiration so they do not run all the time once the day comes.
        staggerOffset += ExpirationStaggerDuration
      } else {
        cache[index] = nil
      }
      do {
        try cache.save(fileName: fileName)
      } catch {
        Logger.atlasCache.error("Cache Save Error: \(error, privacy: .public)")
      }
    }
  }
}
