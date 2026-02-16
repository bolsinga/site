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
    let artists = model.nearbyArtists(nearbyModel, distanceThreshold: nearbyDistance)
    ArtistList(
      artists: artists, sectioner: model.vault.sectioner,
      compare: model.vault.compare(lhs:rhs:),
      filter: { $0.names(filteredBy: $1) }, sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(filteredDataIsEmpty: artists.isEmpty)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  @Previewable @State var searchString = ""
  NavigationStack {
    ArtistsSummary(sort: .alphabetical, searchString: $searchString)
  }
}
