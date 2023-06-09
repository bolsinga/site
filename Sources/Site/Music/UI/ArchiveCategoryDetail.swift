//
//  ArchiveCategoryDetail.swift
//
//
//  Created by Greg Bolsinga on 6/7/23.
//

import SwiftUI

struct ArchiveCategoryDetail: View {
  @Environment(\.vault) private var vault: Vault

  let category: ArchiveCategory?
  @Binding var todayShows: [Show]
  @Binding var venueSort: VenueSort
  @Binding var artistSort: ArtistSort

  private var music: Music {
    vault.music
  }

  @ViewBuilder private var stackElement: some View {
    if let category {
      switch category {
      case .today:
        TodayList(shows: todayShows)
      case .stats:
        List { StatsGrouping(shows: music.shows) }
          .navigationTitle(Text(category.localizedString))
      case .shows:
        ShowYearList()
      case .venues:
        VenueList(venues: music.venues, sort: $venueSort)
      case .artists:
        ArtistList(artists: music.artists, sort: $artistSort)
      }
    } else {
      Text("Select An Item", bundle: .module, comment: "Shown when no ArchiveCategory is selected.")
    }
  }

  var body: some View {
    stackElement
      .musicDestinations()
  }
}

struct ArchiveCategoryDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    ArchiveCategoryDetail(
      category: .today, todayShows: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .stats, todayShows: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .shows, todayShows: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .venues, todayShows: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .artists, todayShows: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical)
    )
    .environment(\.vault, vault)
  }
}
