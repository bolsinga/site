//
//  Location+Geocode.swift
//
//
//  Created by Greg Bolsinga on 2/27/23.
//

import Foundation

#if canImport(Contacts)
  import Contacts
#endif

extension Location: Geocodable {
  #if canImport(Contacts)
    var postalAddress: CNPostalAddress {
      let pAddress = CNMutablePostalAddress()
      pAddress.city = city
      pAddress.state = state
      if let street {
        pAddress.street = street
      }
      return pAddress
    }
  #endif

  var addressString: String {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      let cityState = "\(city), \(state)"
      if let street {
        return "\(street)\n\(cityState)"
      }
      return cityState
    } else {
      #if canImport(Contacts)
        // Note this requests access to Contacts, despite this not reading any contacts.
        return CNPostalAddressFormatter().string(from: postalAddress)
      #else
        let cityState = "\(city) \(state)"
        if let street {
          return "\(street)\n\(cityState)"
        }
        return cityState
      #endif
    }
  }

  func geocode() async throws -> Placemark {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      try await addressString.geocode()
    } else {
      #if canImport(Contacts)
        try await postalAddress.geocode()
      #else
        try await addressString.geocode()
      #endif
    }
  }
}
