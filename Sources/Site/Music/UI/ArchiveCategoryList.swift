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
  @SceneStorage("venue.sort") private var venueSort = VenueSort.alphabetical
  @SceneStorage("artist.sort") private var artistSort = ArtistSort.alphabetical

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
        List { StatsGrouping(shows: music.shows) }
        .navigationTitle(Text(archiveCategory.localizedString))
      case .shows:
        ShowYearList(shows: music.shows)
      case .venues:
        VenueList(venues: music.venues, sort: $venueSort)
      case .artists:
        ArtistList(artists: music.artists, sort: $artistSort)
      }
    }
    .musicDestinations()
    #if os(iOS)
      .navigationBarTitleDisplayMode(.large)
    #endif
    .navigationTitle(Text("Archives", bundle: .module, comment: "Title for the ArchivesList."))
    .onDayChanged {
      self.todayShows = vault.music.showsOnDate(Date.now).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
    }
  }
}
