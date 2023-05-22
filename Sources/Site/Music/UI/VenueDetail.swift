//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct VenueDetail: View {
  @Environment(\.vault) private var vault: Vault

  let venue: Venue

  private var music: Music {
    vault.music
  }

  private var computedRelatedVenues: [Venue] {
    music.related(venue).sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
  }

  private var shows: [Show] {
    music.showsForVenue(venue)
  }

  @ViewBuilder private var locationElement: some View {
    Section(
      header: Text(
        "Location", bundle: .module,
        comment: "Title of the Location / Address Section for VenueDetail.")
    ) {
      AddressView(location: venue.location)
      LocationMap(location: venue.location)
    }
  }

  @ViewBuilder private var statsElement: some View {
    let shows = shows
    if shows.count > 1 {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(shows: shows, kind: .venue)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    Section(
      header: Text("Shows", bundle: .module, comment: "Title of the Shows section of VenueDetail")
    ) {
      ForEach(shows) { show in
        NavigationLink(value: show) { VenueBlurb(show: show) }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    let relatedVenues = computedRelatedVenues
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

  var body: some View {
    List {
      locationElement
      statsElement
      showsElement
      relatedsElement
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle(venue.name)
  }
}

struct VenueDetail_Previews: PreviewProvider {
  static var previews: some View {
    let artist1 = Artist(id: "ar0", name: "Artist With Longer Name")
    let artist2 = Artist(id: "ar1", name: "Artist 2")

    let venue = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")

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
      VenueDetail(venue: venue)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
