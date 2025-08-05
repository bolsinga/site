//
//  ArtistsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct ArtistsSummary: View {
  @Environment(VaultModel.self) var model
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold
  @AppStorage("nearby.filter") private var nearbyFilter = LocationFilter.default

  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let artistDigests = model.filteredArtistDigests(
      locationFilter: nearbyFilter, distanceThreshold: nearbyDistance)
    ArtistList(
      artistDigests: artistDigests, sectioner: model.vault.sectioner, sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(filteredDataIsEmpty: artistDigests.isEmpty)
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  ArtistsSummary(sort: .alphabetical, searchString: .constant(""))
}
