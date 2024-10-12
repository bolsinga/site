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

  @State var artistSearchString: String = ""
  @State var venueSearchString: String = ""

  // The following property allows this UI code to not know if ArchiveNavigation.State.category is Optional or not.
  private var category: ArchiveCategory? { selectedCategory }

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
    if let category {
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
    } else {
      Text("Select An Item", bundle: .module)
    }
  }
}

// Preview only extension
extension ArchiveCategoryDetail {
  init(withPreviewCategory category: ArchiveCategory.DefaultCategory) {
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

#if DEFAULT_CATEGORY_OPTIONAL
  #Preview {
    ArchiveCategoryDetail(withPreviewCategory: nil)
  }
#endif
