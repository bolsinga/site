//
//  ArchiveCategoryStack.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import SwiftUI

struct ArchiveCategoryStack: View {
  let model: VaultModel
  let category: ArchiveCategory
  @Binding var path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  let nearbyModel: NearbyModel

  @State var artistSearchString: String = ""
  @State var venueSearchString: String = ""

  private func sortableData(_ category: ArchiveCategory) -> (
    sort: Binding<RankingSort>, associatedRankName: String
  )? {
    switch category {
    case .today, .stats, .shows:
      nil
    case .venues:
      ($venueSort, String(localized: "Sort By Artist Count", bundle: .module))
    case .artists:
      ($artistSort, String(localized: "Sort By Venue Count", bundle: .module))
    }
  }

  var body: some View {
    NavigationStack(path: $path) {
      category.summary(
        model: model, nearbyModel: nearbyModel,
        venueSortSearch: {
          (venueSort, $venueSearchString)
        },
        artistSortSearch: {
          (artistSort, $artistSearchString)
        }
      )
      .toolbar {
        if category.isLocationFilterable {
          @Bindable var bindableNearbyModel = nearbyModel
          LocationFilterToolbarContent(isOn: $bindableNearbyModel.locationFilter.toggle)
        }
        if let sortableData = sortableData(category) {
          SortModifierToolbarContent(algorithm: sortableData.sort) {
            switch $0 {
            case .associatedRank:
              return sortableData.associatedRankName
            default:
              return $0.localizedString
            }
          }
        }
        ArchiveSharableToolbarContent(
          item: ArchiveCategoryLinkable(vault: model.vault, category: category))
      }
      .musicDestinations(model.vault, path: path)
    }
  }
}

// Preview only extension
extension ArchiveCategoryStack {
  init(withPreviewCategory category: ArchiveCategory) {
    self.init(
      model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false),
      category: category, path: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical), nearbyModel: NearbyModel())
  }
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .today)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .stats)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .shows)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .venues)
}

#Preview {
  ArchiveCategoryStack(withPreviewCategory: .artists)
}
