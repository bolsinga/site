//
//  AtlasCache.swift
//
//
//  Created by Greg Bolsinga on 9/22/23.
//

import CoreLocation
import Foundation
import os

extension Logger {
  static let atlasCache = Logger(category: "atlasCache")
}

private let expirationOffset = 60.0 * 60.0 * 24.0 * 30.0 * 6.0  // Six months

struct AtlasCache<T: AtlasGeocodable> {
  struct Value: Codable {
    @NSCodingCodable
    var placemark: CLPlacemark
    let expirationDate: Date
  }

  let fileName: String
  let stagger: (() -> TimeInterval)  // This allows batch geocodes to be "staggered" in their expiration so they do not run all the time once the day comes.

  var cache: [T: Value] = [:]

  internal init(fileName: String = "atlas.json", stagger: @escaping (() -> TimeInterval)) {
    self.fileName = fileName
    self.stagger = stagger

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

  subscript(index: T) -> CLPlacemark? {
    get {
      cache[index]?.placemark
    }
    set(newValue) {
      if let newValue {
        cache[index] = Value(
          placemark: newValue,
          expirationDate: .now + expirationOffset + stagger())
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
