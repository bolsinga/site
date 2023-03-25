//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct VenueDetail: View {
  @Environment(\.music) var music: Music

  let venue: Venue

  private var relatedVenues: [Venue] {
    music.related(venue).sorted(by: libraryCompare(lhs:rhs:))
  }

  var body: some View {
    VStack(alignment: .leading) {
      List {
        Section(
          header: Text(
            "Location", bundle: .module,
            comment: "Title of the Location / Address Section for VenueDetail.")
        ) {
          AddressView(location: venue.location)
        }
        if !relatedVenues.isEmpty {
          Section(
            header: Text(
              "Related Venues", bundle: .module,
              comment: "Title of the Related Venues Section for VenueDetail.")
          ) {
            ForEach(relatedVenues) { relatedVenue in
              NavigationLink(relatedVenue.name, value: relatedVenue)
            }
          }
        }
      }
      #if os(iOS)
        .listStyle(GroupedListStyle())
      #endif
    }
    .navigationTitle(venue.name)
  }
}

struct VenueDetail_Previews: PreviewProvider {
  static var previews: some View {
    let venue = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")
    VenueDetail(venue: venue)
  }
}
