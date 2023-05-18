//
//  ArtistDetail.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import SwiftUI

struct ArtistDetail: View {
  @Environment(\.vault) private var vault: Vault
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let artist: Artist

  private var music: Music {
    vault.music
  }

  private var computedShows: [Show] {
    return vault.lookup.showsForArtist(artist).sorted {
      vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }
  }

  private func computedYearsOfShows(_ shows: [Show]) -> [PartialDate] {
    return Array(
      Set(shows.map { $0.date.year != nil ? PartialDate(year: $0.date.year!) : PartialDate() })
    ).sorted(by: <)
  }

  private func computedVenuesOfShows(_ shows: [Show]) -> [Venue] {
    Array(
      Set(shows.compactMap { do { return try vault.lookup.venueForShow($0) } catch { return nil } })
    )
  }

  private var computedRelatedArtists: [Artist] {
    music.related(artist).sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
  }

  @ViewBuilder private var statsElement: some View {
    let shows = computedShows
    let yearsOfShows = computedYearsOfShows(shows)
    let venues = computedVenuesOfShows(shows)

    let yearSpan = yearsOfShows.yearSpan()

    if shows.count > 1 || yearSpan > 1 || venues.count > 1 {
      Section(
        header: Text(
          "Stats", bundle: .module, comment: "Title of the stats section for ArtistDetail")
      ) {
        if shows.count > 1 {
          Text("\(shows.count) Show(s)", bundle: .module, comment: "Shows Count for ArtistDetail.")
        }

        if yearSpan > 1 {
          Text(
            "\(yearSpan) Year(s)", bundle: .module,
            comment: "Years Count for ArtistDetail.")
        }

        if venues.count > 1 {
          Text(
            "\(venues.count) Venue(s)", bundle: .module, comment: "Venues Count for ArtistDetail."
          )
        }

        if shows.count > statsThreshold {
          Stats(shows: shows)
        }
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    let shows = computedShows
    if !shows.isEmpty {
      Section(
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of ArtistDetail")
      ) {
        ForEach(shows) { show in
          NavigationLink(value: show) {
            ArtistBlurb(show: show)
          }
        }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    let relatedArtists = computedRelatedArtists
    if !relatedArtists.isEmpty {
      Section(
        header: Text(
          "Related Artists", bundle: .module,
          comment: "Title of the Related Artists Section for ArtistDetail.")
      ) {
        ForEach(relatedArtists) { relatedArtist in
          NavigationLink(relatedArtist.name, value: relatedArtist)
        }
      }
    }
  }

  var body: some View {
    List {
      statsElement
      showsElement
      relatedsElement
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle(artist.name)
  }
}

struct ArtistDetail_Previews: PreviewProvider {
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
      ArtistDetail(artist: artist1)
        .environment(\.vault, vault)
        .musicDestinations()
    }

    NavigationStack {
      ArtistDetail(artist: artist2)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
