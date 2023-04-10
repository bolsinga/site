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
      .tabItem {
        Label(
          String(localized: "Shows", bundle: .module, comment: "Title Of the Show List Tab"),
          systemImage: "person.and.background.dotted")
      }
      NavigationStack {
        LibraryComparableList(items: music.venues.sorted(by: libraryCompare(lhs:rhs:))) {
          String(
            localized: "\(music.showsForVenue($0).count) Show(s)", bundle: .module,
            comment: "Value for the Venue # of Shows.")
        }
        .navigationTitle(Text("Venues", bundle: .module, comment: "Title for the Venue Detail"))
        .musicDestinations()
      }
      .tabItem {
        Label(
          String(localized: "Venues", bundle: .module, comment: "Title Of the Venue List Tab"),
          systemImage: "music.note.house")
      }
      NavigationStack {
        LibraryComparableList(items: music.artistsWithShows().sorted(by: libraryCompare(lhs:rhs:)))
        {
          String(
            localized: "\(music.showsForArtist($0).count) Show(s)", bundle: .module,
            comment: "Value for the Artist # of Shows.")
        }
        .navigationTitle(Text("Artists", bundle: .module, comment: "Title for the Artist Detail"))
        .musicDestinations()
      }
      .tabItem {
        Label(
          String(
            localized: "Artists", bundle: .module, comment: "Title Of the Artist List Tab"),
          systemImage: "music.mic")
      }
    }
  }
}

struct NavigateTab_Previews: PreviewProvider {
  static var previews: some View {
    NavigateTab()
  }
}
