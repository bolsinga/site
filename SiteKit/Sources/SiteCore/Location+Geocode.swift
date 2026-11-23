//
//  Location+Geocode.swift
//
//
//  Created by Greg Bolsinga on 2/27/23.
//

import Foundation
import Shared

extension Location: Geocodable {
  public var addressString: String {
    let cityState = "\(city), \(state)"
    if let street {
      return "\(street)\n\(cityState)"
    }
    return cityState
  }

  public func geocode() async throws -> Placemark {
    try await addressString.geocode()
  }
}
