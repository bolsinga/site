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

extension Location {
  #if canImport(Contacts)
    private var postalAddress: CNPostalAddress {
      let pAddress = CNMutablePostalAddress()
      pAddress.city = city
      pAddress.state = state
      if let street {
        pAddress.street = street
      }
      return pAddress
    }

    var addressString: String {
      // Note this requests access to Contacts, despite this not reading any contacts.
      CNPostalAddressFormatter().string(from: postalAddress)
    }
  #else
    var addressString: String {
      let cityState = "\(city) \(state)"
      if let street {
        return "\(street)\n\(cityState)"
      }
      return cityState
    }
  #endif

  func geocode() async throws -> Placemark {
    #if canImport(Contacts)
      try await geocodePostalAddress(self.postalAddress)
    #else
      try await geocodeAddressString(addressString)
    #endif
  }
}
