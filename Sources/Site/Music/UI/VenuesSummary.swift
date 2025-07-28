//
//  VenuesSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct VenuesSummary: View {
  @Environment(VaultModel.self) var model

  let nearbyModel: NearbyModel
  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let venueDigests = model.filteredVenueDigests(nearbyModel)
    VenueList(
      venueDigests: venueDigests, sectioner: model.vault.sectioner, sort: sort,
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
  VenuesSummary(nearbyModel: NearbyModel(), sort: .alphabetical, searchString: .constant(""))
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
