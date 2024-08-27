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
  var archiveNavigation: ArchiveNavigation
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  var nearbyModel: NearbyModel

  private var vault: Vault { model.vault }

  @State var artistSearchString: String = ""
  @State var venueSearchString: String = ""

  private var category: ArchiveCategory? { archiveNavigation.selectedCategory }
  private var isCategoryActive: Bool { archiveNavigation.navigationPath.isEmpty }

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
      .musicDestinations(vault, navigationPath: archiveNavigation.navigationPath)
  }
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  let archiveNavigation = ArchiveNavigation(selectedCategory: .today)

  return ArchiveCategoryDetail(
    model: vaultModel, archiveNavigation: archiveNavigation, venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  let archiveNavigation = ArchiveNavigation(selectedCategory: .stats)

  return ArchiveCategoryDetail(
    model: vaultModel, archiveNavigation: archiveNavigation, venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  let archiveNavigation = ArchiveNavigation(selectedCategory: .shows)

  return ArchiveCategoryDetail(
    model: vaultModel, archiveNavigation: archiveNavigation, venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  let archiveNavigation = ArchiveNavigation(selectedCategory: .venues)

  return ArchiveCategoryDetail(
    model: vaultModel, archiveNavigation: archiveNavigation, venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), nearbyModel: NearbyModel(vaultModel: vaultModel))
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  let archiveNavigation = ArchiveNavigation(selectedCategory: .artists)

  return ArchiveCategoryDetail(
    model: vaultModel, archiveNavigation: archiveNavigation, venueSort: .constant(.alphabetical),
    artistSort: .constant(.alphabetical), nearbyModel: NearbyModel(vaultModel: vaultModel))
}
