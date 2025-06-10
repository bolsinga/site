//
//  NSError+Throttle.swift
//  site
//
//  Created by Greg Bolsinga on 6/10/25.
//

import CoreLocation

extension NSError {
  var isGeocodingThrottledError: Bool {
    self.code == CLError.network.rawValue && self.domain == kCLErrorDomain
  }
}
