//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 3/24/23.
//

import SwiftUI

struct VenueList: View {
  let venues: [Venue]

  @State private var searchString: String = ""

  private var filteredVenues: [Venue] {
    guard !searchString.isEmpty else { return venues }
    return venues.filter { $0.name.lowercased().contains(searchString.lowercased()) }
  }

  var body: some View {
    List(filteredVenues) { venue in
      NavigationLink(venue.name, value: venue)
    }
    .searchable(text: $searchString)
    .navigationTitle("Venues")
    .navigationDestination(for: Venue.self) { venue in
      VenueDetail(venue: venue)
    }
  }
}

struct VenueList_Previews: PreviewProvider {
  static var previews: some View {
    let venue1 = Venue(
      id: "v11",
      location: Location(
        city: "Oakland", street: "1807 Telegraph Ave.",
        state: "CA"), name: "Fox Theatre")

    let venue2 = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")

    let venues: [Venue] = [venue1, venue2].sorted(by: libraryCompare(lhs:rhs:))
    NavigationStack {
      VenueList(venues: venues)
    }
  }
}
