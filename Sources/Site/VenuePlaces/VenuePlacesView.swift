//
//  VenuePlacesView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Shared
import SwiftUI
import UniformTypeIdentifiers

/// The gate, then the venues once the archive has loaded.
struct VenuePlacesView: View {
  let model: SiteModel

  @State private var store = VenuePickStore()
  @State private var addresses = VenueAddressPickStore()
  @State private var suggestions = VenueSuggestionStore()
  @State private var checks = VenuePlaceChecks()

  var body: some View {
    if !VenuePlaces.isEnabled {
      ContentUnavailableView("Venue Places Unavailable", systemImage: "map")
    } else if let vaultModel = model.vaultModel {
      VenuePlacesSplitView(store: store, addresses: addresses)
        .environment(vaultModel)
        .environment(checks)
        .environment(suggestions)
    } else {
      ProgressView()
    }
  }
}

enum VenuePlacesFilter: CaseIterable, Hashable {
  case all
  case unpicked
  case suggested
  case stale
  case noStreet

  var label: LocalizedStringResource {
    switch self {
    case .all: "All"
    case .unpicked: "Unpicked"
    case .suggested: "Suggested"
    case .stale: "Stale"
    case .noStreet: "No Street"
    }
  }

  func includes(_ digest: VenueDigest, status: VenuePickStatus) -> Bool {
    switch self {
    case .all: true
    case .unpicked: status == .unpicked || status == .suggested
    case .suggested: status == .suggested
    case .stale: status == .stale
    case .noStreet: digest.location.street == nil
    }
  }
}

extension VenuePickStatus {
  var label: LocalizedStringResource {
    switch self {
    case .unpicked: "Unpicked"
    case .suggested: "Suggested"
    case .picked: "Picked"
    case .verified: "Verified"
    case .stale: "Stale"
    case .noPlace: "No Place"
    }
  }

  var systemImage: String {
    switch self {
    case .unpicked: "circle.dashed"
    case .suggested: "sparkle.magnifyingglass"
    case .picked: "mappin.circle.fill"
    case .verified: "checkmark.seal.fill"
    case .stale: "exclamationmark.triangle.fill"
    case .noPlace: "xmark.circle"
    }
  }

  var color: Color {
    switch self {
    case .unpicked, .noPlace: .secondary
    case .suggested: .orange
    case .picked: .accentColor
    case .verified: .green
    case .stale: .red
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

extension PickStore {
  func binding(for venueID: String) -> Binding<Pick?> {
    Binding(get: { self[venueID] }, set: { self[venueID] = $0 })
  }
}

/// When the checks are tried: when geocoding finishes or the venues load.
private struct ChecksTrigger: Equatable {
  let isGeocoding: Bool
  let venues: Int
}

enum VenuePlacesSelection: Hashable {
  case dashboard
  case venue(ArchivePath)
  case sharedLocation(ArchivePath)
}

struct VenuePlacesSplitView: View {
  @Environment(VaultModel.self) private var model
  @Environment(VenuePlaceChecks.self) private var checks
  @Environment(VenueSuggestionStore.self) private var suggestions
  let store: VenuePickStore
  let addresses: VenueAddressPickStore

  @State private var digests: [VenueDigest] = []
  @State private var selection: VenuePlacesSelection? = .dashboard
  @State private var filter = VenuePlacesFilter.all
  @State private var searchString = ""
  @State private var isChoosingVenueMapFolder = false
  /// What writing venuemap.txt did.
  @State private var venueMapMessage: String?
  @State private var isConfirmingClear = false
  /// The venues the saved picks were made for.
  @AppStorage("venuePlaces.venuesFingerprint") private var venuesFingerprint = ""
  /// Where venuemap.txt is written; empty until a folder is chosen.
  @AppStorage("venue-places.venuemap-folder") private var venueMapFolder: VenueMapFolder?

  private var shownDigests: [VenueDigest] {
    digests.filter { digest in
      filter.includes(digest, status: status(digest))
        && (searchString.isEmpty || digest.name.localizedStandardContains(searchString))
    }
  }

  private var sharedLocations: [SharedLocation] {
    SharedLocation.groups(of: digests.map { .init(id: $0.id, location: $0.location) }) {
      model.venueMapItemMap[$0]?.location
    }
  }

  /// Removes the picks, accepted addresses and what the batches found, keeping the venuemap.txt
  /// folder.
  private func clearVenueData() {
    checks.removeAll()
    store.removeAll()
    addresses.removeAll()
  }

  /// Verifies places and suggests them for venues that need one, once every venue has geocoded.
  private func runChecks(again: Bool = false) {
    guard !model.geocodingInProgress, !digests.isEmpty else { return }
    checks.run(digests, store: store, suggestions: suggestions, again: again) {
      model.venueMapItemMap[$0]?.location
    }
  }

  private func writeVenueMap(to folder: VenueMapFolder) {
    let contents = VenueMapFile.contents(
      digests.map(\.venue), picks: store.picks, addresses: addresses.picks)
    do {
      let file = try folder.write(contents)
      venueMapMessage = String(
        localized: "Wrote \(digests.count) venues to \(file.path(percentEncoded: false)).")
    } catch {
      venueMapMessage = String(
        localized: "venuemap.txt can't be written: \(error.localizedDescription)")
    }
  }

  private func status(_ digest: VenueDigest) -> VenuePickStatus {
    checks.status(
      venue: digest.venue, pick: store[digest.venue.id], suggestion: suggestions[digest.venue.id])
  }

  private func digest(_ id: ArchivePath) -> VenueDigest? {
    digests.first { $0.id == id }
  }

  /// The running batch, in the sidebar like the geocoding progress.
  @ViewBuilder private var checksSection: some View {
    if let progress = checks.progress {
      Section {
        HStack {
          ProgressView(value: Double(progress.completed), total: Double(max(progress.total, 1))) {
            Text(progress.title)
          } currentValueLabel: {
            Text("\(progress.completed) of \(progress.total)")
          }
          Button("Cancel", systemImage: "xmark.circle.fill") { checks.cancel() }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
      }
    }
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
    case .dashboard:
      VenuePlacesDashboard(digests: digests, store: store, addresses: addresses) {
        selection = .venue($0)
      }
    case .venue(let id):
      if let digest = digest(id) {
        VenuePlaceDetail(
          digest: digest, pick: store.binding(for: digest.venue.id),
          address: addresses.binding(for: digest.venue.id)
        )
        .id(digest.id)
      }
    case .sharedLocation(let id):
      if let sharedLocation = sharedLocations.first(where: { $0.id == id }) {
        SharedLocationDetail(
          sharedLocation: sharedLocation,
          digests: sharedLocation.venues.compactMap { digest($0.id) }, store: store,
          addresses: addresses
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
        Label("Dashboard", systemImage: "list.bullet.clipboard")
          .tag(VenuePlacesSelection.dashboard)
        checksSection
        sharedLocationsSection
        Section("All Venues") {
          ForEach(shownDigests) { digest in
            VenuePlaceRow(digest: digest, status: status(digest))
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
      ToolbarItemGroup {
        Button("Run Checks Again", systemImage: "arrow.clockwise") {
          runChecks(again: true)
        }
        .help("Run Checks Again")
        .disabled(checks.isRunning || model.geocodingInProgress)
        Menu {
          Button("Choose Folder…") { isChoosingVenueMapFolder = true }
        } label: {
          Label("Write venuemap.txt", systemImage: "square.and.arrow.down")
        } primaryAction: {
          if let folder = venueMapFolder {
            // Storing it again saves a bookmark that was refreshed when it was read.
            venueMapFolder = folder
            writeVenueMap(to: folder)
          } else {
            isChoosingVenueMapFolder = true
          }
        }
        .help("Write venuemap.txt")
        .disabled(digests.isEmpty)
        Button("Clear Saved Data", systemImage: "trash", role: .destructive) {
          isConfirmingClear = true
        }
        .help("Clear Saved Data")
      }
      ToolbarItem {
        Picker("Filter", selection: $filter) {
          ForEach(VenuePlacesFilter.allCases, id: \.self) {
            Text($0.label)
          }
        }
        .pickerStyle(.segmented)
      }
    }
    #if !os(tvOS)
      .fileImporter(isPresented: $isChoosingVenueMapFolder, allowedContentTypes: [.folder]) {
        switch $0 {
        case .success(let folder):
          let folder = VenueMapFolder(folder)
          venueMapFolder = folder
          writeVenueMap(to: folder)
        case .failure(let error):
          venueMapMessage = error.localizedDescription
        }
      }
    #endif
    .confirmationDialog(
      "Clear Saved Data?", isPresented: $isConfirmingClear, titleVisibility: .visible
    ) {
      Button("Clear Saved Data", role: .destructive) {
        clearVenueData()
        suggestions.removeAll()
        venueMapFolder = nil
        runChecks()
      }
    } message: {
      Text(
        "Every pick, accepted address, suggested place and check result, and the venuemap.txt folder are removed. Places are then checked and suggested again. This can't be undone."
      )
    }
    .alert(
      "venuemap.txt",
      isPresented: Binding(
        get: { venueMapMessage != nil }, set: { if !$0 { venueMapMessage = nil } })
    ) {
    } message: {
      Text(venueMapMessage ?? "")
    }
    .overlay(alignment: .bottom) {
      VStack {
        messages
      }
    }
    .task(id: ObjectIdentifier(model)) {
      digests = model.vault.orderedVenueIDs.compactMap { model.vault.digest(venue: $0) }
      // Picks for venue data that has since changed are cleared.
      let current = VenuesFingerprint.fingerprint(digests.map(\.venue))
      if VenuesFingerprint.isChanged(saved: venuesFingerprint, current: current) {
        clearVenueData()
      }
      venuesFingerprint = current
    }
    // Once geocoding is done; venues already checked for their place, name and address are skipped.
    .task(id: ChecksTrigger(isGeocoding: model.geocodingInProgress, venues: digests.count)) {
      runChecks()
    }
  }

  @ViewBuilder private var messages: some View {
    if let error = checks.error {
      Text("The batch stopped: \(error.localizedDescription)")
        .padding()
        .background(.orange.opacity(0.2), in: .rect(cornerRadius: 8))
        .padding()
    }
    if let readError = store.readError ?? addresses.readError ?? suggestions.readError
      ?? checks.readError
    {
      Text(
        "The saved picks can't be read, so changes aren't saved: \(readError.localizedDescription)"
      )
      .padding()
      .background(.red.opacity(0.2), in: .rect(cornerRadius: 8))
      .padding()
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
        .foregroundStyle(status.color)
        .help(Text(status.label))
    }
  }
}
