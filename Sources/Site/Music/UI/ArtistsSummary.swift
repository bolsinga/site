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
    .nearbyLocation(filteredDataIsEmpty: artistDigests.isEmpty)
  }
}

#Preview(traits: .modifier(NearbyPreviewModifer())) {
  ArtistsSummary(sort: .alphabetical, searchString: .constant(""))
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
