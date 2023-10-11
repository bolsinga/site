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
    HStack(alignment: .bottom) {
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

    AddressView(location: vaultPreviewData.venueDigests[0].venue.location)

    let locationWithoutOptionals = Location(city: "Charleston", state: "IL")
    AddressView(location: locationWithoutOptionals)
  }
}
