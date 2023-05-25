//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList: View {
  @Environment(\.vault) private var vault: Vault
  let venues: [Venue]

  var body: some View {
    let algorithm = LibrarySectionAlgorithm.alphabetical
    LibraryComparableList(
      items: venues,
      searchPrompt: String(
        localized: "Venue Names", bundle: .module, comment: "VenueList searchPrompt"),
      sectioner: vault.sectioner(for: algorithm),
      itemContentView: { (venue: Venue) in
        Text(
          "\(vault.lookup.venueRank(venue: venue).count) Show(s)", bundle: .module,
          comment: "Value for the Venue # of Shows.")
      },
      headerView: { section in
        section.representingView
      }
    )
    .navigationTitle(Text("Venues", bundle: .module, comment: "Title for the Venue Detail"))
  }
}

struct VenueList_Previews: PreviewProvider {
  static var previews: some View {
    let venue = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")

    let artist1 = Artist(id: "ar0", name: "An Artist")

    let artist2 = Artist(id: "ar1", name: "Live Only Band")

    let show1 = Show(
      artists: [artist1.id, artist2.id], comment: "The show was Great!",
      date: PartialDate(year: 2001, month: 1, day: 15), id: "sh15", venue: venue.id)

    let show2 = Show(
      artists: [artist1.id, artist2.id], comment: "The show was Great!",
      date: PartialDate(year: 2010, month: 1), id: "sh16", venue: venue.id)

    let show3 = Show(
      artists: [artist1.id],
      date: PartialDate(), id: "sh17", venue: venue.id)

    let music = Music(
      albums: [],
      artists: [artist1, artist2],
      relations: [],
      shows: [show1, show2, show3],
      songs: [],
      timestamp: Date.now,
      venues: [venue])

    let vault = Vault(music: music)

    NavigationStack {
      VenueList(venues: music.venues)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
