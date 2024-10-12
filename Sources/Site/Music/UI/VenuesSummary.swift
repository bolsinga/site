//
//  VenuesSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct VenuesSummary: View {
  let model: VaultModel
  let nearbyModel: NearbyModel
  @Binding var sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let venueDigests = model.filteredVenueDigests(nearbyModel)
    VenueList(
      venueDigests: venueDigests, sectioner: model.vault.sectioner, sort: $sort,
      searchString: $searchString
    )
    .nearbyLocation(
      locationFilter: nearbyModel.locationFilter,
      locationAuthorization: model.locationAuthorization,
      geocodingProgress: model.geocodingProgress, filteredDataIsEmpty: venueDigests.isEmpty
    )
  }
}

#Preview {
  VenuesSummary(
    model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false),
    nearbyModel: NearbyModel(), sort: .constant(.alphabetical), searchString: .constant(""))
}
