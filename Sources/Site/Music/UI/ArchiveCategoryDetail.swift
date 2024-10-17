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

  var body: some View {
    if let category {
      ArchiveCategoryStack(
        model: model, category: category, statsDisplayArchiveCategoryCounts: false, path: $path,
        venueSort: $venueSort, artistSort: $artistSort, nearbyModel: nearbyModel)
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
