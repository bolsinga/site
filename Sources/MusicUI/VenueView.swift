//
//  VenueView.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI
import json

struct VenueView: View {
  let venue: Venue
  var body: some View {
    VStack(alignment: .leading) {
      Text(venue.name)
        .font(.title)
      Divider()
      AddressView(location: venue.location)
    }
  }
}

struct VenueView_Previews: PreviewProvider {
  static var previews: some View {
    let venue = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")
    VenueView(venue: venue)
  }
}
