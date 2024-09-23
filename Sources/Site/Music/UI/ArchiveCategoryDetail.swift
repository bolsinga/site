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
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  let nearbyModel: NearbyModel
  // Pass in the ArchiveCategory for now, so the logic does not need to handle optional values.
  let path: (ArchiveCategory) -> Binding<[ArchivePath]>

  private var vault: Vault { model.vault }

  @State var artistSearchString: String = ""
  @State var venueSearchString: String = ""

  // The following property allows this UI code to not know if ArchiveNavigation.State.category is Optional or not.
  private var category: ArchiveCategory? { selectedCategory }

  var body: some View {
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
      .categoryDetail(vault: vault, category: category, path: path(category))
    } else {
      Text("Select An Item", bundle: .module)
    }
  }
}

// Preview only extension
extension ArchiveCategoryDetail {
  init(withPreviewCategory category: ArchiveCategory) {
    let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
    self.init(
      model: vaultModel, selectedCategory: category, venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), nearbyModel: NearbyModel(vaultModel: vaultModel)
    ) { _ in .constant([]) }
  }
}

#Preview {
  ArchiveCategoryDetail(withPreviewCategory: .today)
}

#Preview {
  ArchiveCategoryDetail(withPreviewCategory: .stats)
}

#Preview {
  ArchiveCategoryDetail(withPreviewCategory: .shows)
}

#Preview {
  ArchiveCategoryDetail(withPreviewCategory: .venues)
}

#Preview {
  ArchiveCategoryDetail(withPreviewCategory: .artists)
}
