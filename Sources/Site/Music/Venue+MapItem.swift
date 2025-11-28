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

extension Venue {
  @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
  fileprivate var mkAddress: MKAddress? {
    MKAddress(fullAddress: location.addressString, shortAddress: nil)
  }
}

extension MKMapItem {
  fileprivate convenience init(venue: Venue, location: CLLocation) {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      self.init(location: location, address: venue.mkAddress)
      self.name = venue.name
    } else {
      #if canImport(Contacts)
        let placemark = MKPlacemark(
          location: location, name: venue.name, postalAddress: venue.location.postalAddress)
      #else
        let placemark = MKPlacemark(coordinate: location.coordinate)
      #endif
      self.init(placemark: placemark)
    }
  }

  convenience init(venue: Venue, placemark: Placemark) {
    self.init(venue: venue, location: placemark.location)
  }
}
