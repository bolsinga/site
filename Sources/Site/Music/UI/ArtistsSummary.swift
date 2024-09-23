//
//  ArtistsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct ArtistsSummary: View {
  let model: VaultModel
  let nearbyModel: NearbyModel
  @Binding var sort: RankingSort
  @Binding var searchString: String

  private var vault: Vault { model.vault }

  var body: some View {
    let artistDigests = model.filteredArtistDigests(nearbyModel)
    ArtistList(
      artistDigests: artistDigests, sectioner: vault.sectioner, sort: $sort,
      searchString: $searchString
    )
    .locationFilter(nearbyModel, filteredDataIsEmpty: artistDigests.isEmpty)
  }
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  ArtistsSummary(
    model: vaultModel, nearbyModel: NearbyModel(vaultModel: vaultModel),
    sort: .constant(.alphabetical), searchString: .constant(""))
}
