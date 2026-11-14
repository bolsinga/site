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
  @State private var websites = VenueWebsitePickStore()
  @State private var suggestions = VenueSuggestionStore()
  @State private var checks = VenuePlaceChecks()

  var body: some View {
    if !VenuePlaces.isEnabled {
      ContentUnavailableView("Venue Places Unavailable", systemImage: "map")
    } else if let vaultModel = model.vaultModel {
      VenuePlacesSplitView(store: store, addresses: addresses, websites: websites)
        .environment(vaultModel)
        .environment(checks)
        .environment(suggestions)
    } else {
      ProgressView()
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
    case .stale: "Place Changed or Gone"
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

struct VenuePlacesSplitView: View {
  @Environment(VaultModel.self) private var model
  @Environment(VenuePlaceChecks.self) private var checks
  @Environment(VenueSuggestionStore.self) private var suggestions
  let store: VenuePickStore
  let addresses: VenueAddressPickStore
  let websites: VenueWebsitePickStore

  @State private var digests: [VenueDigest] = []
  @State private var selection: ArchivePath?
  /// Always showing the venue list, which dragging it small would otherwise collapse.
  @State private var columnVisibility = NavigationSplitViewVisibility.all
  @State private var filter: VenuePlacesFilter?
  @State private var searchString = ""
  @State private var isChoosingVenueMapFolder = false
  /// What writing venuemap.txt did.
  @State private var venueMapMessage: String?
  /// Where venuemap.txt is written; none until the first save chooses a folder.
  @State private var venueMapFolder: VenueMapFolder?

  /// Whether a pick or address changed since venuemap.txt was written.
  private var isEdited: Bool { store.isEdited || addresses.isEdited || websites.isEdited }

  /// The venues that geocode to the same point as others, by venue.
  private var sharedLocationMap: [ArchivePath: SharedLocation] {
    let groups = SharedLocation.groups(of: digests.map { .init(id: $0.id, location: $0.location) }) {
      model.venueMapItemMap[$0]?.location
    }
    return groups.reduce(into: [:]) { map, group in
      for venue in group.venues { map[venue.id] = group }
    }
  }

  private func facts(_ digest: VenueDigest, shared: SharedLocation?) -> VenueFacts {
    let id = digest.venue.id
    let verification = checks.verification(venue: digest.venue, pick: store[id])
    var replaced = false
    var gone = false
    switch verification {
    case .replaced: replaced = true
    case .notFound: gone = true
    case .verified, nil: break
    }
    return VenueFacts(
      status: status(digest),
      isModified: store[id] != nil || addresses[id] != nil || websites[id] != nil,
      hasStreet: digest.location.street != nil,
      sharesLocation: shared.map { $0.cause != .noStreet } ?? false,
      hasWebsite: (websites[id] ?? digest.location.web) != nil,
      websiteNeedsALook: websiteNotes(digest).issue != nil,
      hasPlace: digest.venue.placeIdentifier(pick: store[id]) != nil,
      addressDiffers: AddressCheck(
        venue: addresses.address(for: digest.venue), maps: model.venueMapsAddressMap[digest.id]
      ).differingAddress != nil,
      identifierChanged: replaced, placeGone: gone)
  }

  private func websiteNotes(_ digest: VenueDigest) -> [VenueWebsiteNote] {
    checks.websiteNotes(
      for: digest, pick: store[digest.venue.id],
      web: websites[digest.venue.id] ?? digest.location.web)
  }

  private var shownDigests: [VenueDigest] {
    let shared = sharedLocationMap
    return digests.filter { digest in
      (filter?.includes(facts(digest, shared: shared[digest.id])) ?? true)
        && (searchString.isEmpty || digest.name.localizedStandardContains(searchString))
    }
  }

  /// Verifies places and suggests them for venues that need one, once every venue has geocoded.
  private func runChecks(again: Bool = false) {
    guard !model.geocodingInProgress, !digests.isEmpty else { return }
    checks.run(
      digests, store: store, suggestions: suggestions, websites: websites, again: again
    ) {
      model.venueMapItemMap[$0]?.location
    }
  }

  private func writeVenueMap(to folder: VenueMapFolder) {
    let contents = VenueMapFile.contents(
      digests.map(\.venue), picks: store.picks, addresses: addresses.picks,
      websites: websites.picks)
    do {
      let file = try folder.write(contents)
      store.markSaved()
      addresses.markSaved()
      websites.markSaved()
      venueMapMessage = String(
        localized: "Wrote \(digests.count) venues to \(file.path(percentEncoded: false)).")
    } catch {
      venueMapMessage = String(
        localized: "venuemap.txt can't be written: \(error.localizedDescription)")
    }
  }

  /// Writes venuemap.txt to the folder chosen before, or asks for one.
  private func save() {
    if let venueMapFolder {
      writeVenueMap(to: venueMapFolder)
    } else {
      isChoosingVenueMapFolder = true
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
  @ViewBuilder private var progressSection: some View {
    if model.geocodingInProgress {
      Section {
        ProgressView(value: model.geocodingProgress) {
          Text("Geocoding Venues")
        }
      }
    }
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

  @ViewBuilder private var detail: some View {
    if let selection, let selected = digest(selection) {
      let group = sharedLocationMap[selected.id]
      VenuePlaceDetail(
        digest: selected, pick: store.binding(for: selected.venue.id),
        address: addresses.binding(for: selected.venue.id),
        website: websites.binding(for: selected.venue.id),
        sharedWith: group?.venues.filter { $0.id != selected.id }.compactMap { digest($0.id) }
          ?? [],
        sharedCause: group?.cause
      )
      .id(selected.id)
    } else {
      ContentUnavailableView("Choose a Venue", systemImage: "mappin.and.ellipse")
    }
  }

  /// A filter that is on while it's chosen, and off when it's chosen again.
  private func filterToggle(_ option: VenuePlacesFilter) -> some View {
    Toggle(
      isOn: Binding(
        get: { filter == option },
        set: { filter = $0 ? option : nil })
    ) {
      Text(option.label)
    }
  }

  private var filterMenu: some View {
    Menu {
      Section("Status") {
        ForEach(VenuePlacesFilter.statuses, id: \.self) { filterToggle($0) }
      }
      Section("Criteria") {
        ForEach(VenuePlacesFilter.criteria, id: \.self) { filterToggle($0) }
      }
    } label: {
      Label(
        filter.map { String(localized: $0.label) } ?? String(localized: "Filter"),
        systemImage: filter == nil
          ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
    }
    .help("Filter")
  }

  /// Why no venue is listed.
  @ViewBuilder private var noVenues: some View {
    if let filter {
      ContentUnavailableView {
        Label("No Venues", systemImage: "line.3.horizontal.decrease.circle")
      } description: {
        Text(
          searchString.isEmpty
            ? "No venues match “\(String(localized: filter.label))”."
            : "No venues match “\(String(localized: filter.label))” and “\(searchString)”.")
        if checks.isRunning || model.geocodingInProgress {
          Text("Checks are still running, so more may match soon.")
        }
        Text("Choose the filter again in the filter menu to turn it off.")
      }
    } else {
      ContentUnavailableView.search(text: searchString)
    }
  }

  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      List(selection: $selection) {
        progressSection
        Section("\(shownDigests.count) Venues") {
          ForEach(shownDigests) { digest in
            VenuePlaceRow(
              digest: digest, status: status(digest), websiteNotes: websiteNotes(digest))
              .tag(digest.id)
          }
        }
      }
      #if os(tvOS)
        .searchable(text: $searchString)
      #else
        .searchable(text: $searchString, placement: .sidebar)
      #endif
      .overlay {
        if shownDigests.isEmpty && !digests.isEmpty { noVenues }
      }
      // The list always shows, so it has no button to hide it.
      .toolbar(removing: .sidebarToggle)
      // In the sidebar's toolbar, so it sits by the list it filters.
      .toolbar {
        ToolbarItem {
          filterMenu
        }
      }
      .navigationSplitViewColumnWidth(min: 240, ideal: 300)
    } detail: {
      detail
    }
    .onChange(of: columnVisibility) {
      if columnVisibility != .all { columnVisibility = .all }
    }
    .toolbar {
      ToolbarItemGroup {
        Button("Run Checks Again", systemImage: "arrow.clockwise") {
          runChecks(again: true)
        }
        .help("Run Checks Again")
        .disabled(checks.isRunning || model.geocodingInProgress)
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
    #if !os(tvOS)
      .dismissalConfirmationDialog("Save Changes?", shouldPresent: isEdited) {
        // Without a folder, saving needs one chosen first, so it's left to the Save command.
        if venueMapFolder != nil {
          Button("Save") { save() }
        }
        Button("Don't Save", role: .destructive) {}
      } message: {
        Text(
          venueMapFolder == nil
            ? "There are changes that haven't been saved to venuemap.txt. Cancel, then choose File > Save."
            : "There are changes that haven't been saved to venuemap.txt.")
      }
    #endif
    .windowEdited(isEdited)
    .focusedSceneValue(
      \.venuePlacesActions,
      VenuePlacesActions(save: save, saveAs: { isChoosingVenueMapFolder = true }))
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
        .sorted { ($0.sortname ?? $0.name).localizedStandardCompare($1.sortname ?? $1.name) == .orderedAscending }
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

struct VenuePlaceRow: View {
  let digest: VenueDigest
  let status: VenuePickStatus
  let websiteNotes: [VenueWebsiteNote]

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(digest.name)
        Text("\(digest.location.city), \(digest.location.state)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      if let issue = websiteNotes.issue {
        Image(systemName: issue.systemImage)
          .foregroundStyle(issue.severity.color)
          .help(websiteNotes.map(\.text).joined(separator: "\n"))
      }
      Image(systemName: status.systemImage)
        .foregroundStyle(status.color)
        .help(Text(status.label))
    }
  }
}
