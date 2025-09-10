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
    HStack(alignment: .center) {
      Text(location.addressString)
      if let web = location.web {
        Spacer()
        Link(destination: web) {
          Image(systemName: "safari")
        }.help(web.absoluteString)
      }
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  AddressView(location: model.vault.venueDigests[0].venue.location)
}

#Preview {
  AddressView(location: Location(city: "Charleston", state: "IL"))
}
