//
//  NSError+Geocoding.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation

extension Int {
  fileprivate var isThrottledCode: Bool {
    self == CLError.network.rawValue
  }

  fileprivate var matchesGeocodingCode: Bool {
    switch self {
    case CLError.geocodeFoundNoResult.rawValue, CLError.geocodeFoundPartialResult.rawValue,
      CLError.geocodeCanceled.rawValue:
      true
    default:
      false
    }
  }
}

extension String {
  fileprivate var isGeocodingDomain: Bool {
    self == kCLErrorDomain
  }
}

extension NSError {
  fileprivate var isGeocodingError: Bool {
    self.domain.isGeocodingDomain
  }

  var isGeocodingThrottledError: Bool {
    self.isGeocodingError && self.code.isThrottledCode
  }

  var isGeocodingFailureError: Bool {
    self.isGeocodingError && self.code.matchesGeocodingCode
  }
}
