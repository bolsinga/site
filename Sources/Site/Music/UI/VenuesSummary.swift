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
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let venues = model.nearbyVenues(nearbyModel, distanceThreshold: nearbyDistance)
    VenueList(
      venues: venues, sectioner: model.vault.sectioner,
      compare: model.vault.compare(lhs:rhs:),
      filter: { $0.names(filteredBy: $1) }, sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(filteredDataIsEmpty: venues.isEmpty)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  @Previewable @State var searchString = ""
  NavigationStack {
    VenuesSummary(sort: .alphabetical, searchString: $searchString)
  }
}
