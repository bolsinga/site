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
  @Binding var cityString: String
  @Binding var mode: VenuesMode
  let navigateToPath: (ArchivePath) -> Void

  @State private var mapRequested = false

  /// The search as the map sees it. It follows typing once it pauses, so the map doesn't re-fit
  /// for every keystroke.
  @State private var mapSearchString = ""
  @State private var mapSearchSettled = false

  private var cityField: some View {
    HStack {
      Image(systemName: "mappin.and.ellipse")
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
      TextField(String(localized: "City Name"), text: $cityString)
        #if os(iOS)
          .textInputAutocapitalization(.words)
          .submitLabel(.done)
        #endif
        .autocorrectionDisabled()
      if !cityString.isEmpty {
        Button {
          cityString = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "Clear City"))
      } else if let currentCity = model.currentCity {
        Button {
          cityString = currentCity
        } label: {
          Label(currentCity, systemImage: "location.fill")
            .labelStyle(.titleAndIcon)
            .font(.subheadline)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .accessibilityLabel(String(localized: "Use \(currentCity)"))
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(.regularMaterial, in: .rect(cornerRadius: 10))
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
  }

  private func seedCity() {
    guard let city = model.currentCity else { return }
    if let seed = defaultCity(
      current: city, typed: cityString, alreadySeeded: model.currentCityOffered)
    {
      cityString = seed
    }
    model.currentCityOffered = true
  }

  var body: some View {
    let venues = model.nearbyVenues(nearbyModel, distanceThreshold: nearbyDistance)
      .cities(filteredBy: cityString)
    let cityFiltered = !cityString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
          summary: venues.isEmpty || cityFiltered
            ? nil
            : .venues(
              count: venues.count,
              stats: Stats(
                statisticsData: model.filteredStatisticsData(
                  nearbyModel, distanceThreshold: nearbyDistance)))
        )
        .overlay {
          if cityFiltered, venues.isEmpty {
            ContentUnavailableView.search(text: cityString)
          }
        }
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
          .searchable(text: $searchString, prompt: String(localized: "Venue Names"))
          #if os(iOS)
            .searchToolbarBehavior(.minimize)
          #endif
      }
    }
    .safeAreaInset(edge: .top, spacing: 0) {
      cityField
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
    .onChange(of: model.currentCity, initial: true) {
      seedCity()
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
  @Previewable @State var cityString = ""
  @Previewable @State var mode = VenuesMode.default
  NavigationStack {
    VenuesSummary(
      sort: .alphabetical, searchString: $searchString, cityString: $cityString, mode: $mode
    ) { _ in }
  }
}
