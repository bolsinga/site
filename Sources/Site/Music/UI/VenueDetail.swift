//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct VenueDetail: View {
  @Environment(\.vault) private var vault: Vault
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let venue: Venue

  private var music: Music {
    vault.music
  }

  private var computedRelatedVenues: [Venue] {
    music.related(venue).sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
  }

  private var shows: [Show] {
    vault.lookup.showsForVenue(venue)
  }

  private var computedYearsOfShows: [PartialDate] {
    return Array(
      Set(shows.map { $0.date.year != nil ? PartialDate(year: $0.date.year!) : PartialDate() })
    ).sorted(by: <)
  }

  private var computedArtists: [Artist] {
    vault.lookup.artistsForVenue(venue).sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
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
    let yearsOfShows = computedYearsOfShows
    let artists = computedArtists

    let yearSpan = yearsOfShows.yearSpan()

    if shows.count > 1 || yearSpan > 1 || artists.count > 1 {
      Section(
        header: Text(
          "Stats", bundle: .module, comment: "Title of the stats section for VenueDetail")
      ) {
        if shows.count > 1 {
          Text("\(shows.count) Show(s)", bundle: .module, comment: "Shows Count for VenueDetail.")
        }

        if yearSpan > 1 {
          Text(
            "\(yearSpan) Year(s)", bundle: .module,
            comment: "Years Count for VenueDetail.")
        }

        if artists.count > 1 {
          Text(
            "\(artists.count) Artist(s)", bundle: .module, comment: "Artists Count for VenueDetail."
          )
        }

        if shows.count > statsThreshold {
          Stats(shows: shows)
        }
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
