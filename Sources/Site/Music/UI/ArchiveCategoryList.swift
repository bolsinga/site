//
//  ArchiveCategoryList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

public struct ArchiveCategoryList: View {
  let vault: Vault

  @State private var navigationPath: NavigationPath = .init()
  @State private var todayShows: [Show] = []

  private var music: Music {
    vault.music
  }

  @ViewBuilder private func archiveCount(_ archiveCategory: ArchiveCategory) -> some View {
    switch archiveCategory {
    case .today:
      Text(todayShows.count.formatted(.number))
    case .stats:
      EmptyView()
    case .shows:
      Text(music.shows.count.formatted(.number))
    case .venues:
      Text(music.venues.count.formatted(.number))
    case .artists:
      Text(music.artists.count.formatted(.number))
    }
  }

  public var body: some View {
    NavigationStack(path: $navigationPath) {
      List(ArchiveCategory.allCases, id: \.self) { archiveCategory in
        NavigationLink(value: archiveCategory) {
          LabeledContent {
            archiveCount(archiveCategory)
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
          ArchiveStats(shows: music.shows)
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
    }.task {
      async let todayShows = vault.lookup.showsOnDate(Date.now).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }

      self.todayShows = await todayShows
    }
    .environment(\.vault, vault)
  }
}

struct ArchiveCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault(
      music: Music(
        albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date.now,
        venues: []))

    ArchiveCategoryList(vault: vault)
  }
}
