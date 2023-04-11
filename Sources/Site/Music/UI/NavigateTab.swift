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
    TabView {
      NavigationStack {
        ShowYearList(shows: music.shows.sorted(by: music.showCompare(lhs:rhs:)))
          .musicDestinations()
      }
      .tabItem { ArchiveCategory.shows.label }
      NavigationStack {
        VenueList(venues: music.venues.sorted(by: libraryCompare(lhs:rhs:)))
          .musicDestinations()
      }
      .tabItem { ArchiveCategory.venues.label }
      NavigationStack {
        ArtistList(artists: music.artistsWithShows().sorted(by: libraryCompare(lhs:rhs:)))
          .musicDestinations()
      }
      .tabItem { ArchiveCategory.artists.label }
    }
  }
}

struct NavigateTab_Previews: PreviewProvider {
  static var previews: some View {
    NavigateTab()
  }
}
