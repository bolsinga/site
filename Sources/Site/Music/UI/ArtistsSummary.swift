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
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let artistDigests = model.filteredArtistDigests(nearbyModel, distanceThreshold: nearbyDistance)
    ArtistList(
      artistDigests: artistDigests, sectioner: model.vault.sectioner,
      compare: model.vault.comparator.libraryCompare(lhs:rhs:), sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(filteredDataIsEmpty: artistDigests.isEmpty)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  ArtistsSummary(sort: .alphabetical, searchString: .constant(""))
}
