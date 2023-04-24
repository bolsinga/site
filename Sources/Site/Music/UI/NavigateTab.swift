//
//  NavigateTab.swift
//
//
//  Created by Greg Bolsinga on 3/27/23.
//

import SwiftUI

public struct NavigateTab: View {
  @Environment(\.vault) private var vault: Vault

  private var music: Music {
    vault.music
  }

  public init() {
  }

  public var body: some View {
    TabView {
      NavigationStack {
        ShowYearList(
          shows: music.shows.sorted {
            vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
          }
        )
        .musicDestinations()
      }
      .tabItem { ArchiveCategory.shows.label }
      NavigationStack {
        VenueList(venues: music.venues.sorted(by: vault.comparator.libraryCompare(lhs:rhs:)))
          .musicDestinations()
      }
      .tabItem { ArchiveCategory.venues.label }
      NavigationStack {
        ArtistList(
          artists: vault.lookup.artistsWithShows().sorted(
            by: vault.comparator.libraryCompare(lhs:rhs:))
        )
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
