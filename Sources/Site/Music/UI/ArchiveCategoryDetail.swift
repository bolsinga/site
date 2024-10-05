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
  let selectedCategory: ArchiveCategory.DefaultCategory
  @Binding var path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  let nearbyModel: NearbyModel

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
          TodaySummary(model: model)
        case .stats:
          StatsSummary(vault: vault)
        case .shows:
          ShowsSummary(model: model, nearbyModel: nearbyModel)
        case .venues:
          VenuesSummary(
            model: model, nearbyModel: nearbyModel, sort: $venueSort,
            searchString: $venueSearchString)
        case .artists:
          ArtistsSummary(
            model: model, nearbyModel: nearbyModel, sort: $artistSort,
            searchString: $artistSearchString)
        }
      }
      .categoryDetail(vault: vault, category: category, path: $path)
    } else {
      Text("Select An Item", bundle: .module)
    }
  }
}

// Preview only extension
extension ArchiveCategoryDetail {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false),
      selectedCategory: category, path: .constant([]),
      venueSort: .constant(.alphabetical), artistSort: .constant(.alphabetical),
      nearbyModel: NearbyModel())
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
