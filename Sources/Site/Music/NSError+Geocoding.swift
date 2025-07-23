//
//  NSError+Geocoding.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation
import MapKit

extension Int {
  fileprivate var isThrottledCode: Bool {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      return self == MKError.loadingThrottled.rawValue
    } else {
      return self == CLError.network.rawValue
    }
  }

  fileprivate var matchesGeocodingCode: Bool {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      return self == MKError.placemarkNotFound.rawValue
    } else {
      switch self {
      case CLError.geocodeFoundNoResult.rawValue, CLError.geocodeFoundPartialResult.rawValue,
        CLError.geocodeCanceled.rawValue:
        return true
      default:
        return false
      }
    }
  }
}

extension String {
  fileprivate var isGeocodingDomain: Bool {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      return self == MKErrorDomain
    } else {
      return self == kCLErrorDomain
    }
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
