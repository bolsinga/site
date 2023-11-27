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
  @Binding var locationFilter: LocationFilter
  let nearbyDistanceThreshold: CLLocationDistance

  private var vault: Vault { model.vault }

  private var filteredDecadesMap: [Decade: [Annum: [Concert.ID]]] {
    locationFilter.isNearby ? model.decadesMapsNearby(nearbyDistanceThreshold) : vault.decadesMap
  }

  private var filteredVenueDigests: [VenueDigest] {
    locationFilter.isNearby ? model.venueDigestsNearby(nearbyDistanceThreshold) : vault.venueDigests
  }

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
          ShowYearList(decadesMap: filteredDecadesMap)
            .locationFilter(
              $locationFilter, geocodingProgress: model.geocodingProgress,
              locationAuthorization: model.locationAuthorization,
              filteredDataIsEmpty: filteredDecadesMap.isEmpty)
        case .venues:
          VenueList(
            venueDigests: filteredVenueDigests, sectioner: vault.sectioner, sort: $venueSort
          )
          .locationFilter(
            $locationFilter, geocodingProgress: model.geocodingProgress,
            locationAuthorization: model.locationAuthorization,
            filteredDataIsEmpty: filteredVenueDigests.isEmpty)
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
    isCategoryActive: true, locationFilter: .constant(.none), nearbyDistanceThreshold: 1.0)
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .stats,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none), nearbyDistanceThreshold: 1.0)
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .shows,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none), nearbyDistanceThreshold: 1.0)
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .venues,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none), nearbyDistanceThreshold: 1.0)
}

#Preview {
  ArchiveCategoryDetail(
    model: VaultModel(vaultPreviewData), category: .artists,
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    isCategoryActive: true, locationFilter: .constant(.none), nearbyDistanceThreshold: 1.0)
}
