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
  let category: ArchiveCategory?
  @Binding var path: [ArchivePath]
  @Binding var venueSort: RankingSort
  @Binding var artistSort: RankingSort
  let nearbyModel: NearbyModel

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
  init(withPreviewCategory category: ArchiveCategory?) {
    self.init(
      model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false),
      category: category, path: .constant([]), venueSort: .constant(.alphabetical),
      artistSort: .constant(.alphabetical),
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

#Preview {
  ArchiveCategoryDetail(withPreviewCategory: nil)
}
