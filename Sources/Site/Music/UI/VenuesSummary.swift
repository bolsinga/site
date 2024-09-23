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

  private var vault: Vault { model.vault }

  var body: some View {
    let venueDigests = model.filteredVenueDigests(nearbyModel)
    VenueList(
      venueDigests: venueDigests, sectioner: vault.sectioner, sort: $sort,
      searchString: $searchString
    )
    .locationFilter(nearbyModel, filteredDataIsEmpty: venueDigests.isEmpty)
  }
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  VenuesSummary(
    model: vaultModel, nearbyModel: NearbyModel(vaultModel: vaultModel),
    sort: .constant(.alphabetical), searchString: .constant(""))
}
