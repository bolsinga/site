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

  @State private var mapRequested = false

  var body: some View {
    Picker(selection: $mode) {
      ForEach(VenuesMode.allCases, id: \.self) {
        Image(systemName: $0.systemImage)
      }
    } label: {
    }
    .pickerStyle(.segmented)

    let venues = model.nearbyVenues(nearbyModel, distanceThreshold: nearbyDistance)
    ZStack {
      // The map stays once it has been shown, so toggling back doesn't rebuild it.
      if mapRequested || mode == .map {
        VenuesMap(items: venues, isShown: mode == .map, navigateToPath: navigateToPath)
          .opacity(mode == .map ? 1 : 0)
          .allowsHitTesting(mode == .map)
          .accessibilityHidden(mode != .map)
      }

      switch mode {
      case .grouped:
        VenueList(
          venues: venues,
          compare: model.compare(lhs:rhs:),
          sort: sort,
          searchString: $searchString
        )
      case .map:
        Color.clear
          .allowsHitTesting(false)
          .navigationTitle(ArchiveCategory.venues.localizedString)
          #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
          #endif
          .archiveSearchable(
            searchPrompt: String(localized: "Venue Names"),
            searchString: $searchString,
            contentsEmpty: venues.isEmpty
          )
      }
    }
    .onChange(of: mode, initial: true) { _, mode in
      if mode == .map {
        mapRequested = true
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
