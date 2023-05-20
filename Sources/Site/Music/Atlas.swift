//
//  Atlas.swift
//
//
//  Created by Greg Bolsinga on 5/1/23.
//

import CoreLocation
import Foundation
import MapKit

actor Atlas {
  internal var cache: [Location: CLPlacemark] = [:]

  public func geocode(_ location: Location) async throws -> CLPlacemark {
    if let result = cache[location] {
      return result
    }
    let result: CLPlacemark = try await location.geocode()
    cache[location] = result
    return result
  }
}
