//
//  ArchiveCategoryDetail.swift
//
//
//  Created by Greg Bolsinga on 6/7/23.
//

import CoreLocation
import SwiftUI

struct ArchiveCategoryDetail: View {
  let model: VaultModel
  let selectedCategory: ArchiveNavigation.State.DefaultCategory
  let path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  let nearbyModel: NearbyModel

  private var vault: Vault { model.vault }

  @State var artistSearchString: String = ""
  @State var venueSearchString: String = ""

  // The following property allows this UI code to not know if ArchiveNavigation.State.category is Optional or not.
  private var category: ArchiveCategory? { selectedCategory }
  private var isCategoryActive: Bool { path.isEmpty }

  @MainActor
  @ViewBuilder private var stackElement: some View {
    if let category {
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
          VenueList(
            venueDigests: venueDigests, sectioner: vault.sectioner, sort: $venueSort,
            searchString: $venueSearchString
          )
          .locationFilter(nearbyModel, filteredDataIsEmpty: venueDigests.isEmpty)
        case .artists:
          let artistDigests = model.filteredArtistDigests(nearbyModel)
          ArtistList(
            artistDigests: artistDigests, sectioner: vault.sectioner, sort: $artistSort,
            searchString: $artistSearchString
          )
          .locationFilter(nearbyModel, filteredDataIsEmpty: artistDigests.isEmpty)
        }
      }
      .shareActivity(for: category, vault: vault, isActive: isCategoryActive)
    } else {
      Text("Select An Item", bundle: .module)
    }
  }

  var body: some View {
    stackElement
      .musicDestinations(vault, path: path)
  }
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)

  return ArchiveCategoryDetail(
    model: vaultModel, selectedCategory: .today, path: [],
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)

  return ArchiveCategoryDetail(
    model: vaultModel, selectedCategory: .stats, path: [],
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)

  return ArchiveCategoryDetail(
    model: vaultModel, selectedCategory: .shows, path: [],
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)

  return ArchiveCategoryDetail(
    model: vaultModel, selectedCategory: .venues, path: [],
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)

  return ArchiveCategoryDetail(
    model: vaultModel, selectedCategory: .artists, path: [],
    venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
    nearbyModel: NearbyModel(vaultModel: vaultModel))
}
