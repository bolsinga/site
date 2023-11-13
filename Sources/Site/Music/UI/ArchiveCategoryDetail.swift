//
//  ArchiveCategoryDetail.swift
//
//
//  Created by Greg Bolsinga on 6/7/23.
//

import SwiftUI

struct ArchiveCategoryDetail: View {
  let vault: Vault
  let category: ArchiveCategory?
  let todayConcerts: [Concert]
  let nearbyConcerts: [Concert]
  @Binding var venueSort: VenueSort
  @Binding var artistSort: ArtistSort
  let isCategoryActive: Bool
  @Binding var locationFilter: LocationFilter
  let geocodingProgress: Double
  let locationAuthorization: LocationAuthorization

  @MainActor
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
          ShowYearList(
            decadesMap: vault.decadesMap, nearbyConcertIDs: Set(nearbyConcerts.map { $0.id }),
            locationFilter: $locationFilter, geocodingProgress: geocodingProgress,
            locationAuthorization: locationAuthorization)
        case .venues:
          VenueList(
            venueDigests: vault.venueDigests,
            nearbyVenueIDs: Set(nearbyConcerts.compactMap { $0.venue?.id }),
            sectioner: vault.sectioner, sort: $venueSort,
            locationFilter: $locationFilter, geocodingProgress: geocodingProgress,
            locationAuthorization: locationAuthorization)
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
    vault: vaultPreviewData, category: .today, todayConcerts: [],
    nearbyConcerts: [], venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), isCategoryActive: true,
    locationFilter: .constant(.none), geocodingProgress: 0.5,
    locationAuthorization: .allowed)
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, category: .stats, todayConcerts: [],
    nearbyConcerts: [], venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), isCategoryActive: true,
    locationFilter: .constant(.none), geocodingProgress: 0.5,
    locationAuthorization: .allowed)
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, category: .shows, todayConcerts: [],
    nearbyConcerts: [], venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), isCategoryActive: true,
    locationFilter: .constant(.none), geocodingProgress: 0.5,
    locationAuthorization: .allowed)
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, category: .venues, todayConcerts: [],
    nearbyConcerts: [], venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), isCategoryActive: true,
    locationFilter: .constant(.none), geocodingProgress: 0.5,
    locationAuthorization: .allowed)
}

#Preview {
  ArchiveCategoryDetail(
    vault: vaultPreviewData, category: .artists, todayConcerts: [],
    nearbyConcerts: [], venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), isCategoryActive: true,
    locationFilter: .constant(.none), geocodingProgress: 0.5,
    locationAuthorization: .allowed)
}
