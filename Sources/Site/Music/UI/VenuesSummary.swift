//
//  VenuesSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct VenuesSummary: View {
  @Environment(VaultModel.self) var model
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold
  @AppStorage("nearby.filter") private var nearbyFilter = LocationFilter.default

  let sort: RankingSort
  @Binding var searchString: String

  var body: some View {
    let venueDigests = model.filteredVenueDigests(
      locationFilter: nearbyFilter, distanceThreshold: nearbyDistance)
    VenueList(
      venueDigests: venueDigests, sectioner: model.vault.sectioner, sort: sort,
      searchString: $searchString
    )
    .nearbyLocation(filteredDataIsEmpty: venueDigests.isEmpty)
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  VenuesSummary(sort: .alphabetical, searchString: .constant(""))
}
