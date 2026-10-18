//
//  VenuesSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import MapKit
import Shared
import SwiftUI

struct VenuesSummary: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  let sort: RankingSort
  @Binding var searchString: String
  @Binding var mode: VenuesMode
  let navigateToPath: (ArchivePath) -> Void

  var body: some View {
    Picker(selection: $mode) {
      ForEach(VenuesMode.allCases, id: \.self) {
        Image(systemName: $0.systemImage)
      }
    } label: {
    }
    .pickerStyle(.segmented)

    let venues = model.nearbyVenues(nearbyModel, distanceThreshold: nearbyDistance)
    Group {
      switch mode {
      case .grouped:
        VenueList(
          venues: venues,
          compare: model.compare(lhs:rhs:),
          sort: sort,
          searchString: $searchString
        )
      case .map:
        VenuesMap(items: venues, searchString: $searchString, navigateToPath: navigateToPath)
      }
    }
    .nearbyLocation(filteredDataIsEmpty: venues.isEmpty)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  @Previewable @State var searchString = ""
  @Previewable @State var mode = VenuesMode.default
  NavigationStack {
    VenuesSummary(sort: .alphabetical, searchString: $searchString, mode: $mode) { _ in }
  }
}
