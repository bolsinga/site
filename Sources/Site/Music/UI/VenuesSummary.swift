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
  @Binding var scope: VenueSearchScope
  @Binding var mode: VenuesMode
  let navigateToPath: (ArchivePath) -> Void

  @State private var mapRequested = false

  /// The search as the map sees it. It follows typing once it pauses, so the map doesn't re-fit
  /// for every keystroke.
  @State private var mapSearchString = ""
  @State private var mapSearchSettled = false
  #if !os(tvOS)
    @FocusState private var searchFocused: Bool
  #endif

  @ViewBuilder private var currentCitySuggestions: some View {
    if let city = currentCitySuggestion(current: model.currentCity, searchText: searchString) {
      Button {
        scope = .cities
        searchString = city
      } label: {
        Label {
          VStack(alignment: .leading) {
            Text(city)
            Text("Current Location")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        } icon: {
          Image(systemName: "location")
        }
      }
    }
  }

  /// The scope's prompt shows once search is focused.
  private var searchPrompt: String {
    #if os(tvOS)
      scope.searchPrompt
    #else
      searchFocused ? scope.searchPrompt : VenueSearchScope.idlePrompt
    #endif
  }

  @ViewBuilder private var scopeOptions: some View {
    ForEach(VenueSearchScope.allCases, id: \.self) {
      Text($0.localizedString).tag($0)
    }
  }

  var body: some View {
    let nearby = model.nearbyVenues(nearbyModel, distanceThreshold: nearbyDistance)
    let cityScope = scope == .cities
    let venues = cityScope ? nearby.cities(filteredBy: searchString) : nearby
    let cityFiltered = cityScope && !searchString.trimmingCharacters(in: .whitespaces).isEmpty
    let mapVenues =
      cityScope
      ? nearby.cities(filteredBy: mapSearchString) : nearby.names(filteredBy: mapSearchString)
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
          summary: venues.isEmpty || cityFiltered
            ? nil
            : .venues(
              count: venues.count,
              stats: Stats(
                statisticsData: model.filteredStatisticsData(
                  nearbyModel, distanceThreshold: nearbyDistance))),
          scope: scope,
          searchPrompt: searchPrompt
        )
      case .map:
        Color.clear
          .allowsHitTesting(false)
          .overlay(alignment: .bottom) {
            if (!mapSearchString.isEmpty || cityFiltered), mapVenues.isEmpty {
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
          .searchable(text: $searchString, prompt: searchPrompt)
          #if os(iOS)
            .searchToolbarBehavior(.minimize)
          #endif
      }
    }
    #if os(tvOS)
      .searchScopes($scope) { scopeOptions }
    #else
      .searchScopes($scope, activation: .onSearchPresentation) { scopeOptions }
    #endif
    #if !os(tvOS)
      .searchFocused($searchFocused)
    #endif
    .searchSuggestions {
      currentCitySuggestions
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
  @Previewable @State var scope = VenueSearchScope.names
  @Previewable @State var mode = VenuesMode.default
  NavigationStack {
    VenuesSummary(
      sort: .alphabetical, searchString: $searchString, scope: $scope, mode: $mode
    ) { _ in }
  }
}
