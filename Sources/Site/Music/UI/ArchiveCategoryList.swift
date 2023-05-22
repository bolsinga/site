//
//  ArchiveCategoryList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import Combine
import SwiftUI

public struct ArchiveCategoryList: View {
  @Environment(\.vault) private var vault: Vault

  @State private var todayShows: [Show] = []

  private var music: Music {
    vault.music
  }

  public var body: some View {
    List(ArchiveCategory.allCases, id: \.self) { archiveCategory in
      NavigationLink(value: archiveCategory) {
        LabeledContent {
          switch archiveCategory {
          case .today:
            Text(todayShows.count.formatted(.number))
            .animation(.easeInOut)
          case .stats:
            EmptyView()
          case .shows:
            Text(music.shows.count.formatted(.number))
          case .venues:
            Text(music.venues.count.formatted(.number))
          case .artists:
            Text(music.artists.count.formatted(.number))
          }
        } label: {
          archiveCategory.label
        }
      }
    }
    .navigationDestination(for: ArchiveCategory.self) { archiveCategory in
      switch archiveCategory {
      case .today:
        TodayList(shows: todayShows)
      case .stats:
        StatsList(shows: music.shows)
      case .shows:
        ShowYearList(shows: music.shows)
      case .venues:
        VenueList(venues: music.venues)
      case .artists:
        ArtistList(artists: music.artists)
      }
    }
    .musicDestinations()
    #if os(iOS)
      .navigationBarTitleDisplayMode(.large)
    #endif
    .navigationTitle(Text("Archives", bundle: .module, comment: "Title for the ArchivesList."))
    .determinateTimer(trigger: .atMidnight) {
      self.todayShows = vault.lookup.showsOnDate(Date.now).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
    }
    //    .task {
    //      for await (location, placemark) in await vault.atlas.geocodedLocations {
    //        print("geocoded: \(location) to \(placemark)")
    //      }
    //    }
  }
}

struct ArchiveCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault(
      music: Music(
        albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date.now,
        venues: []))

    ArchiveCategoryList()
      .environment(\.vault, vault)
  }
}
