//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import CoreLocation
import Foundation

actor Atlas {
  typealias Cache = [Location: CLPlacemark]
  typealias CacheChangeElement = (Cache.Key, Cache.Value?)
  typealias ValueChangeAction = (CacheChangeElement) -> Void

  private var cache: Cache = [:]
  private var action: ValueChangeAction? = nil

  public func geocode(_ location: Location) async throws -> CLPlacemark {
    if let result = self[location] {
      return result
    }
    let result: CLPlacemark = try await location.geocode()
    self[location] = result
    return result
  }

  subscript(index: Location) -> CLPlacemark? {
    get {
      cache[index]
    }
    set(newValue) {
      cache[index] = newValue
      action?(CacheChangeElement(index, newValue))
    }
  }

  var geocodedLocations: AsyncStream<CacheChangeElement> {
    guard action == nil else { fatalError("only one Atlas.AsyncStream") }

    return AsyncStream { continuation in
      // Send what we already may have.
      for element in cache {
        continuation.yield(CacheChangeElement(element.key, element.value))
      }
      // Now observe.
      action = { element in
        continuation.yield(element)
      }
    }
  }
}
