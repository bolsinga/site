//
//  VenuesSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct VenuesSummary: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel

  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let venueDigests = model.filteredVenueDigests(nearbyModel)
    VenueList(
      venueDigests: venueDigests, sectioner: model.vault.sectioner, sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(filteredDataIsEmpty: venueDigests.isEmpty)
  }
}

#Preview {
  VenuesSummary(sort: .alphabetical, searchString: .constant(""))
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}
