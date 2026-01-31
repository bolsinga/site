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
    let venueDigests = model.filteredVenueDigests(nearbyModel, distanceThreshold: nearbyDistance)
    VenueList(
      venues: venueDigests, sectioner: model.vault.sectioner,
      compare: model.vault.comparator.libraryCompare(lhs:rhs:),
      filter: { $0.names(filteredBy: $1) }, sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(filteredDataIsEmpty: venueDigests.isEmpty)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  @Previewable @State var searchString = ""
  NavigationStack {
    VenuesSummary(sort: .alphabetical, searchString: $searchString)
  }
}
