//
//  ArchiveCategoryDetail.swift
//
//
//  Created by Greg Bolsinga on 6/7/23.
//

import SwiftUI

struct ArchiveCategoryDetail: View {
  let vault: Vault
  var model: VaultModel
  let category: ArchiveCategory?
  @Binding var venueSort: VenueSort
  @Binding var artistSort: ArtistSort
  let isCategoryActive: Bool
  @Binding var locationFilter: LocationFilter

  @MainActor
  @ViewBuilder private var stackElement: some View {
    if let category {
      let url = vault.createURL(forCategory: category)
      ZStack {
        switch category {
        case .today:
          TodayList(concerts: model.todayConcerts)
        case .stats:
          List { StatsGrouping(concerts: vault.concerts, displayArchiveCategoryCounts: false) }
            .navigationTitle(Text(category.localizedString))
        case .shows:
          ShowYearList(
            decadesMap: vault.decadesMap, nearbyConcertIDs: Set(model.nearbyConcerts.map { $0.id }),
            locationFilter: $locationFilter, geocodingProgress: model.geocodingProgress,
            locationAuthorization: model.locationAuthorization)
        case .venues:
          VenueList(
            venueDigests: vault.venueDigests,
            nearbyVenueIDs: Set(model.nearbyConcerts.compactMap { $0.venue?.id }),
            sectioner: vault.sectioner, sort: $venueSort,
            locationFilter: $locationFilter, geocodingProgress: model.geocodingProgress,
            locationAuthorization: model.locationAuthorization)
        case .artists:
          ArtistList(
            artistDigests: vault.artistDigests, sectioner: vault.sectioner, sort: $artistSort)
        }
      }
      .shareCategory(category, url: url)
      .archiveCategoryUserActivity(category, url: url, isActive: isCategoryActive)
    } else {
      Text("Select An Item", bundle: .module)
    }
  }

  var body: some View {
    stackElement
      .musicDestinations(vault)
  }
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, model: vaultModelPreviewData, category: .today,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none))
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, model: vaultModelPreviewData, category: .stats,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none))
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, model: vaultModelPreviewData, category: .shows,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none))
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, model: vaultModelPreviewData, category: .venues,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none))
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, model: vaultModelPreviewData, category: .artists,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none))
}
