//
//  VenuePlacesView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Shared
import SwiftUI

/// The gate, then the venues once the archive has loaded.
struct VenuePlacesView: View {
  let model: SiteModel

  @State private var store = VenuePickStore()

  var body: some View {
    if !VenuePlaces.isEnabled {
      ContentUnavailableView("Venue Places Unavailable", systemImage: "map")
    } else if let vaultModel = model.vaultModel {
      VenuePlacesSplitView(store: store)
        .environment(vaultModel)
    } else {
      ProgressView()
    }
  }
}

enum VenuePlacesFilter: CaseIterable, Hashable {
  case all
  case unpicked
  case noStreet

  var label: LocalizedStringResource {
    switch self {
    case .all: "All"
    case .unpicked: "Unpicked"
    case .noStreet: "No Street"
    }
  }

  func includes(_ digest: VenueDigest, pick: VenuePick?) -> Bool {
    switch self {
    case .all: true
    case .unpicked: VenuePickStatus(pick) == .unpicked
    case .noStreet: digest.location.street == nil
    }
  }
}

extension VenuePickStatus {
  var label: LocalizedStringResource {
    switch self {
    case .unpicked: "Unpicked"
    case .picked: "Picked"
    case .noPlace: "No Place"
    }
  }

  var systemImage: String {
    switch self {
    case .unpicked: "circle.dashed"
    case .picked: "mappin.circle.fill"
    case .noPlace: "xmark.circle"
    }
  }
}

extension SharedLocation.Cause {
  var label: LocalizedStringResource {
    switch self {
    case .noStreet: "No street, so the city center"
    case .sameAddress: "Same address"
    case .vagueAddress: "Vague address"
    }
  }
}

extension VenuePickStore {
  func binding(for venueID: String) -> Binding<VenuePick?> {
    Binding(get: { self[venueID] }, set: { self[venueID] = $0 })
  }
}

enum VenuePlacesSelection: Hashable {
  case venue(ArchivePath)
  case sharedLocation(ArchivePath)
}

struct VenuePlacesSplitView: View {
  @Environment(VaultModel.self) private var model
  let store: VenuePickStore

  @State private var digests: [VenueDigest] = []
  @State private var selection: VenuePlacesSelection?
  @State private var filter = VenuePlacesFilter.all
  @State private var searchString = ""

  private var shownDigests: [VenueDigest] {
    digests.filter { digest in
      filter.includes(digest, pick: store[digest.venue.id])
        && (searchString.isEmpty || digest.name.localizedStandardContains(searchString))
    }
  }

  private var sharedLocations: [SharedLocation] {
    SharedLocation.groups(of: digests.map { .init(id: $0.id, location: $0.location) }) {
      model.venueMapItemMap[$0]?.location
    }
  }

  private func digest(_ id: ArchivePath) -> VenueDigest? {
    digests.first { $0.id == id }
  }

  @ViewBuilder private var sharedLocationsSection: some View {
    Section("Shared Locations") {
      if model.geocodingInProgress {
        ProgressView(value: model.geocodingProgress) {
          Text("Geocoding Venues")
        }
      } else {
        ForEach(sharedLocations) { sharedLocation in
          SharedLocationRow(sharedLocation: sharedLocation)
            .tag(VenuePlacesSelection.sharedLocation(sharedLocation.id))
        }
      }
    }
  }

  @ViewBuilder private var detail: some View {
    switch selection {
    case .venue(let id):
      if let digest = digest(id) {
        VenuePlaceDetail(digest: digest, pick: store.binding(for: digest.venue.id))
          .id(digest.id)
      }
    case .sharedLocation(let id):
      if let sharedLocation = sharedLocations.first(where: { $0.id == id }) {
        SharedLocationDetail(
          sharedLocation: sharedLocation,
          digests: sharedLocation.venues.compactMap { digest($0.id) }, store: store
        )
        .id(id)
      } else {
        ContentUnavailableView("No Longer Shared", systemImage: "mappin.slash")
      }
    case nil:
      ContentUnavailableView("Choose a Venue", systemImage: "mappin.and.ellipse")
    }
  }

  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        sharedLocationsSection
        Section("All Venues") {
          ForEach(shownDigests) { digest in
            VenuePlaceRow(digest: digest, status: VenuePickStatus(store[digest.venue.id]))
              .tag(VenuePlacesSelection.venue(digest.id))
          }
        }
      }
      #if os(tvOS)
        .searchable(text: $searchString)
      #else
        .searchable(text: $searchString, placement: .sidebar)
      #endif
      .navigationSplitViewColumnWidth(min: 240, ideal: 300)
    } detail: {
      detail
    }
    .toolbar {
      Picker("Filter", selection: $filter) {
        ForEach(VenuePlacesFilter.allCases, id: \.self) {
          Text($0.label)
        }
      }
      .pickerStyle(.segmented)
    }
    .overlay(alignment: .bottom) {
      if let readError = store.readError {
        Text(
          "The saved picks can't be read, so changes aren't saved: \(readError.localizedDescription)"
        )
        .padding()
        .background(.red.opacity(0.2), in: .rect(cornerRadius: 8))
        .padding()
      }
    }
    .task(id: ObjectIdentifier(model)) {
      digests = model.vault.orderedVenueIDs.compactMap { model.vault.digest(venue: $0) }
    }
  }
}

private struct SharedLocationRow: View {
  let sharedLocation: SharedLocation

  var body: some View {
    VStack(alignment: .leading) {
      if let first = sharedLocation.venues.first {
        Text("\(sharedLocation.venues.count) in \(first.location.city), \(first.location.state)")
      }
      Text(sharedLocation.cause.label)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}

struct VenuePlaceRow: View {
  let digest: VenueDigest
  let status: VenuePickStatus

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(digest.name)
        Text("\(digest.location.city), \(digest.location.state)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Image(systemName: status.systemImage)
        .foregroundStyle(status == .picked ? Color.accentColor : .secondary)
        .help(Text(status.label))
    }
  }
}
