//
//  ArtistsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct ArtistsSummary: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel

  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let artistDigests = model.filteredArtistDigests(nearbyModel)
    ArtistList(
      artistDigests: artistDigests, sectioner: model.vault.sectioner, sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(
      locationFilter: nearbyModel.locationFilter,
      locationAuthorization: model.locationAuthorization,
      geocodingProgress: model.geocodingProgress, filteredDataIsEmpty: artistDigests.isEmpty
    )
  }
}

#Preview {
  ArtistsSummary(sort: .alphabetical, searchString: .constant(""))
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}
