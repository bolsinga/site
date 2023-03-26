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

  private var shows: [Show] {
    music.showsForVenue(venue)
  }

  private var yearsOfShows: [Int] {
    return Array(Set(shows.map { $0.date.normalizedYear })).sorted(by: <)
  }

  var body: some View {
    VStack(alignment: .leading) {
      List {
        Section(
          header: Text(
            "Location", bundle: .module,
            comment: "Title of the Location / Address Section for VenueDetail.")
        ) {
          VStack(alignment: .leading) {
            AddressView(location: venue.location)
            Divider()
            Text(
              "\(shows.count) Show(s)", bundle: .module,
              comment: "Number of shows seen at this venue.")
          }
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
        if !yearsOfShows.isEmpty {
          Section(
            header: Text(
              "Shows By Year", bundle: .module,
              comment: "Title of the Shows by Year Section for VenueDetail.")
          ) {
            ForEach(yearsOfShows, id: \.self) { year in
              Text(String(year))
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
