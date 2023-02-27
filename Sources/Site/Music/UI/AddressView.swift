//
//  AddressView.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct AddressView: View {
  let location: Location

  var body: some View {
    HStack {
      Text(location.addressString)
      if let web = location.web {
        Link(destination: web) {
          Image(systemName: "safari")
        }.help(web.absoluteString)
      }
    }
  }
}

struct AddressView_Previews: PreviewProvider {
  static var previews: some View {
    let location = Location(
      city: "San Francisco",
      web: URL(string: "http://www.amoeba.com"),
      street: "1855 Haight St.",
      state: "CA")
    AddressView(location: location)

    let locationWithoutOptionals = Location(city: "Charleston", state: "IL")
    AddressView(location: locationWithoutOptionals)
  }
}
