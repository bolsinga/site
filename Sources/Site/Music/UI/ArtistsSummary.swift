//
//  ArtistsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import Shared
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
      artists: artists,
      compare: model.compare(lhs:rhs:),
      sort: sort,
      searchString: $searchString,
      summary: .artists(count: artists.count)
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
