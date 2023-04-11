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
          ShowYearList(shows: music.shows.sorted(by: music.showCompare(lhs:rhs:)))
        case .venues:
          VenueList(venues: music.venues.sorted(by: libraryCompare(lhs:rhs:)))
        case .artists:
          ArtistList(artists: music.artistsWithShows().sorted(by: libraryCompare(lhs:rhs:)))
        }
      }
      .musicDestinations()
    }
  }
}

struct ArchiveCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    ArchiveCategoryList()
  }
}
