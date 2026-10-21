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

  /// The search as the map sees it. It follows typing once it pauses, so the map doesn't re-fit
  /// for every keystroke.
  @State private var mapSearchString = ""
  @State private var mapSearchSettled = false

  var body: some View {
    let venues = model.nearbyVenues(nearbyModel, distanceThreshold: nearbyDistance)
    let mapVenues = venues.names(filteredBy: mapSearchString)
    ZStack {
      // The map stays once it has been shown, so toggling back doesn't rebuild it.
      if mapRequested || mode == .map {
        VenuesMap(items: mapVenues, searchString: mapSearchString, navigateToPath: navigateToPath)
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
          searchString: $searchString,
          summary: .venues(count: venues.count)
        )
      case .map:
        Color.clear
          .allowsHitTesting(false)
          .overlay(alignment: .bottom) {
            if !mapSearchString.isEmpty, mapVenues.isEmpty {
              Text("No Matches")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: .capsule)
                .padding(.bottom, 16)
            }
          }
          .navigationTitle(ArchiveCategory.venues.localizedString)
          #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
          #endif
          .searchable(text: $searchString, prompt: String(localized: "Venue Names"))
          #if os(iOS)
            .searchToolbarBehavior(.minimize)
          #endif
      }
    }
    .task(id: searchString) {
      if mapSearchSettled {
        try? await Task.sleep(for: .milliseconds(400))
      }
      guard !Task.isCancelled else { return }
      mapSearchString = searchString
      mapSearchSettled = true
    }
    .onChange(of: mode, initial: true) { _, mode in
      if mode == .map {
        mapRequested = true
      }
    }
    .nearbyLocation(filteredDataIsEmpty: venues.isEmpty, floatsProgress: mode == .map)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Picker(selection: $mode) {
          ForEach(VenuesMode.allCases, id: \.self) {
            // The label is what VoiceOver reads for the icon.
            Label($0.localizedString, systemImage: $0.systemImage)
              .labelStyle(.iconOnly)
          }
        } label: {
        }
        .pickerStyle(.segmented)
      }
    }
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  @Previewable @State var searchString = ""
  @Previewable @State var mode = VenuesMode.default
  NavigationStack {
    VenuesSummary(sort: .alphabetical, searchString: $searchString, mode: $mode) { _ in }
  }
}
