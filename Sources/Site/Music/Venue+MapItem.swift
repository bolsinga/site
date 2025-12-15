//
//  Venue+MapItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/12/25.
//

import MapKit

extension Venue {
  fileprivate var mkAddress: MKAddress? {
    MKAddress(fullAddress: location.addressString, shortAddress: nil)
  }
}

extension MKMapItem {
  convenience init(venue: Venue, location: CLLocation) {
    self.init(location: location, address: venue.mkAddress)
    self.name = venue.name
  }
}
