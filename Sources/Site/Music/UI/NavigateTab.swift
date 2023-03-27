//
//  NavigateTab.swift
//
//
//  Created by Greg Bolsinga on 3/27/23.
//

import SwiftUI

public struct NavigateTab: View {
  @Environment(\.music) private var music: Music

  public init() {
  }

  public var body: some View {
    NavigationStack {
      TabView {
        ShowYearList(shows: music.shows.sorted(by: music.showCompare(lhs:rhs:)))
          .tabItem { Label("Shows", systemImage: "person.and.background.dotted") }
        VenueList(venues: music.venues.sorted(by: libraryCompare(lhs:rhs:)))
          .tabItem { Label("Venues", systemImage: "music.note.house") }
        ArtistList(artists: music.artistsWithShows().sorted(by: libraryCompare(lhs:rhs:)))
          .tabItem { Label("Artists", systemImage: "music.mic") }
      }
      .navigationDestination(for: Show.self) { show in
        ShowDetail(show: show)
      }
      .navigationDestination(for: Venue.self) { venue in
        VenueDetail(venue: venue)
      }
      .navigationDestination(for: Artist.self) { artist in
        ArtistDetail(artist: artist)
      }
    }
  }
}

struct NavigateTab_Previews: PreviewProvider {
  static var previews: some View {
    NavigateTab()
  }
}
