//
//  Venue+MapItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/12/25.
//

import MapKit

#if canImport(Contacts)
  import Contacts
#endif

extension MKMapItem {
  convenience init(venue: Venue, location: CLLocation) {
    #if canImport(Contacts)
      let placemark = MKPlacemark(
        location: location, name: venue.name, postalAddress: venue.location.postalAddress)
    #else
      let placemark = MKPlacemark(coordinate: location.coordinate)
    #endif
    self.init(placemark: placemark)
  }
}
