//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import CoreLocation
import Foundation

actor Atlas {
  private var cache: [Location: CLPlacemark] = [:]

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
    }
  }
}
