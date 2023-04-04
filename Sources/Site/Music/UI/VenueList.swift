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

  private var filteredSections: [String] {
    return Set(filteredVenues.map { librarySection($0) }).sorted()
  }

  private func filteredVenues(for section: String) -> [Venue] {
    return filteredVenues.filter { librarySection($0) == section }
  }

  var body: some View {
    VStack {
      List {
        ForEach(filteredSections, id: \.self) { section in
          Section(section) {
            ForEach(filteredVenues(for: section)) { venue in
              NavigationLink(venue.name, value: venue)
            }
          }
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchString)
      .navigationTitle(Text("Venues", bundle: .module, comment: "Title for the Venue Detail"))
      Divider()
      Text(
        "\(filteredVenues.count) / \(venues.count) Venues", bundle: .module,
        comment:
          "Venue count shown at the bottom of the VenueList."
      )
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

    let music = Music(
      albums: [],
      artists: [],
      relations: [],
      shows: [],
      songs: [],
      timestamp: Date.now,
      venues: [venue1, venue2])

    NavigationStack {
      VenueList(venues: music.venues)
        .environment(\.music, music)
    }
  }
}
