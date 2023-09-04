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
      let url = vault.createURL(forCategory: category)
      ZStack {
        switch category {
        case .today:
          TodayList(concerts: todayConcerts)
        case .stats:
          List { StatsGrouping(concerts: vault.concerts, displayArchiveCategoryCounts: false) }
            .navigationTitle(Text(category.localizedString))
        case .shows:
          ShowYearList(decadesMap: vault.lookup.decadesMap)
        case .venues:
          VenueList(venueDigests: vault.venueDigests, sectioner: vault.sectioner, sort: $venueSort)
        case .artists:
          ArtistList(
            artistDigests: vault.artistDigests, sectioner: vault.sectioner, sort: $artistSort)
        }
      }
      .shareCategory(category, url: url)
      .archiveCategoryUserActivity(category, url: url, isActive: $isCategoryActive)
    } else {
      Text("Select An Item", bundle: .module, comment: "Shown when no ArchiveCategory is selected.")
    }
  }

  var body: some View {
    stackElement
      .musicDestinations(vault)
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
