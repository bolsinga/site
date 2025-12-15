//
//  NSError+Geocoding.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import MapKit

extension Int {
  fileprivate var isThrottledCode: Bool {
    self == MKError.loadingThrottled.rawValue
  }

  fileprivate var matchesGeocodingCode: Bool {
    self == MKError.placemarkNotFound.rawValue
  }
}

extension String {
  fileprivate var isGeocodingDomain: Bool {
    self == MKErrorDomain
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
