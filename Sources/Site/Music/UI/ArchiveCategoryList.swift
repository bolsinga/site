//
//  ArchiveCategoryList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

public struct ArchiveCategoryList: View {
  @Environment(\.music) private var music: Music

  @State private var navigationPath: NavigationPath = .init()
  @State private var shows: [Show] = []
  @State private var venues: [Venue] = []
  @State private var artists: [Artist] = []

  public init() {}

  public var body: some View {
    NavigationStack(path: $navigationPath) {
      List(ArchiveCategory.allCases, id: \.self) { archiveCategory in
        NavigationLink(value: archiveCategory) {
          archiveCategory.label
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
    }.task {
      async let shows = music.shows.sorted(by: music.showCompare(lhs:rhs:))
      async let venues = music.venues.sorted(by: libraryCompare(lhs:rhs:))
      async let artists = music.artistsWithShows().sorted(by: libraryCompare(lhs:rhs:))

      let (s, v, a) = await (shows, venues, artists)

      self.shows = s
      self.venues = v
      self.artists = a
    }
  }
}

struct ArchiveCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    ArchiveCategoryList()
  }
}
