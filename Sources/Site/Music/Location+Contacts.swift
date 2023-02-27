//
//  Location+Contacts.swift
//
//
//  Created by Greg Bolsinga on 2/27/23.
//

import Contacts
import Foundation

extension Location {
  var postalAddress: CNPostalAddress {
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
}
