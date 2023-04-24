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
  @State private var shows: [Show] = []
  @State private var venues: [Venue] = []
  @State private var artists: [Artist] = []

  public init(vault: Vault) { self.vault = vault }

  private var music: Music {
    vault.music
  }

  @ViewBuilder private func archiveCount(_ archiveCategory: ArchiveCategory) -> some View {
    switch archiveCategory {
    case .shows:
      Text(shows.count.formatted(.number))
    case .venues:
      Text(venues.count.formatted(.number))
    case .artists:
      Text(artists.count.formatted(.number))
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
        case .shows:
          ShowYearList(shows: shows)
        case .venues:
          VenueList(venues: venues)
        case .artists:
          ArtistList(artists: artists)
        }
      }
      .musicDestinations()
      #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
      #endif
      .navigationTitle(Text("Archives", bundle: .module, comment: "Title for the ArchivesList."))
    }.task {
      async let shows = music.shows.sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
      async let venues = music.venues.sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
      async let artists = vault.lookup.artistsWithShows().sorted(
        by: vault.comparator.libraryCompare(lhs:rhs:))

      self.shows = await shows
      self.venues = await venues
      self.artists = await artists
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
