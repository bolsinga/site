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
  @Binding var todayConcerts: [Concert]
  @Binding var venueSort: VenueSort
  @Binding var artistSort: ArtistSort
  @Binding var isCategoryActive: Bool

  @ViewBuilder private var stackElement: some View {
    if let category {
      switch category {
      case .today:
        TodayList(concerts: todayConcerts)
          .shareCategory(category)
          .archiveCategoryUserActivity(category, isActive: $isCategoryActive)
      case .stats:
        List { StatsGrouping(shows: vault.shows, displayArchiveCategoryCounts: false) }
          .navigationTitle(Text(category.localizedString))
          .shareCategory(category)
          .archiveCategoryUserActivity(category, isActive: $isCategoryActive)
      case .shows:
        ShowYearList()
          .shareCategory(category)
          .archiveCategoryUserActivity(category, isActive: $isCategoryActive)
      case .venues:
        VenueList(venues: vault.venues, sort: $venueSort)
          .shareCategory(category)
          .archiveCategoryUserActivity(category, isActive: $isCategoryActive)
      case .artists:
        ArtistList(artists: vault.artists, sort: $artistSort)
          .shareCategory(category)
          .archiveCategoryUserActivity(category, isActive: $isCategoryActive)
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
      category: .today, todayConcerts: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), isCategoryActive: .constant(true)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .stats, todayConcerts: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), isCategoryActive: .constant(true)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .shows, todayConcerts: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), isCategoryActive: .constant(true)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .venues, todayConcerts: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), isCategoryActive: .constant(true)
    )
    .environment(\.vault, vault)

    ArchiveCategoryDetail(
      category: .artists, todayConcerts: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), isCategoryActive: .constant(true)
    )
    .environment(\.vault, vault)
  }
}
