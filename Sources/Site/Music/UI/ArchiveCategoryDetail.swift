//
//  ArchiveCategoryDetail.swift
//
//
//  Created by Greg Bolsinga on 6/7/23.
//

import CoreLocation
import SwiftUI

struct ArchiveCategoryDetail: View {
  var model: VaultModel
  let category: ArchiveCategory?
  @Binding var venueSort: VenueSort
  @Binding var artistSort: ArtistSort
  let isCategoryActive: Bool
  var nearbyModel: NearbyModel

  private var vault: Vault { model.vault }

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
          let decadesMap = model.filteredDecadesMap(nearbyModel)
          ShowYearList(decadesMap: decadesMap)
            .locationFilter(nearbyModel, filteredDataIsEmpty: decadesMap.isEmpty)
        case .venues:
          let venueDigests = model.filteredVenueDigests(nearbyModel)
          VenueList(venueDigests: venueDigests, sectioner: vault.sectioner, sort: $venueSort)
            .locationFilter(nearbyModel, filteredDataIsEmpty: venueDigests.isEmpty)
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
    model: VaultModel(vaultPreviewData), category: .today,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, nearbyModel: NearbyModel())
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .stats,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, nearbyModel: NearbyModel())
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .shows,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, nearbyModel: NearbyModel())
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .venues,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, nearbyModel: NearbyModel())
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .artists,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, nearbyModel: NearbyModel())
}
