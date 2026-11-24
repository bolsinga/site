//
//  VenuePlaceDetail.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import MapKit
import SiteCore
import SwiftUI

/// A venue's address, show history, the places in Maps and websites it might have, and its picks.
struct VenuePlaceDetail: View {
  @Environment(VaultModel.self) private var model
  @Environment(VenuePlaceChecks.self) private var checks
  @Environment(VenueSuggestionStore.self) private var suggestions

  let digest: VenueDigest
  @Binding var pick: VenuePick?
  /// The accepted address; unaccepted venues keep the archive's.
  @Binding var address: VenueAddress?
  /// The picked website; unpicked venues keep the archive's.
  @Binding var website: URL?
  /// The other venues that geocode to the same point, and why they do.
  var sharedWith: [VenueDigest] = []
  var sharedCause: SharedLocation.Cause?

  @State private var candidates: [MKMapItem] = []
  @State private var isSearching = false
  @State private var hasSearched = false
  @State private var selectedCandidate: String?
  /// Whether a click on the map places a pin.
  @State private var isPlacingPin = false
  @State private var newPin: CLLocationCoordinate2D?
  /// Where the pick is, found the way the app finds a venue.
  @State private var pickedPlace: MKMapItem?
  @State private var pickedPlaceError: Error?
  @State private var previewedWebsite: URL?
  /// The websites being loaded.
  @State private var checkingWebsites: Set<URL> = []
  @State private var otherWebsite = ""

  private static var headlinerCount: Int { 5 }

  private var shows: [ShowDigest] { digest.shows.sorted() }

  /// Where the venue geocodes from its address.
  private var geocodedLocation: CLLocation? { model.venueMapItemMap[digest.id]?.location }

  /// The first few distinct headliners, in show order.
  private var headliners: [String] {
    var seen = Set<ArchivePath>()
    return shows.compactMap { show in
      guard let headliner = show.performers.first, seen.insert(headliner.id).inserted else {
        return nil
      }
      return headliner.name
    }
    .prefix(Self.headlinerCount).map { $0 }
  }

  /// The place suggested for an unpicked venue.
  private var suggestion: (place: FoundPlace, confidence: SuggestionConfidence)? {
    pick == nil ? suggestions[digest.venue.id]?.offered : nil
  }

  /// The place's identifier: the pick's, or the archive's when unpicked.
  private var pickedIdentifier: String? {
    digest.venue.placeIdentifier(pick: pick)
  }

  private var pickDescription: String {
    switch pick {
    case nil:
      digest.venue.mapKitID.map { String(localized: "Unpicked, so the archive's: \($0)") }
        ?? String(localized: "Unpicked")
    case .place(let identifier, let address, _):
      [pickedPlace?.name, address, identifier].compactMap { $0 }.joined(separator: "\n")
    case .coordinate(let latitude, let longitude):
      String(localized: "Pin: \(latitude), \(longitude)")
    case .noPlace: String(localized: "No Place")
    }
  }

  var body: some View {
    Form {
      Section {
        Text(digest.location.addressString)
          #if !os(tvOS)
            .textSelection(.enabled)
          #endif
        if digest.location.street == nil {
          Label("No street", systemImage: "exclamationmark.triangle")
            .foregroundStyle(.orange)
        }
        mapsAddress
        if let sharedCause, !sharedWith.isEmpty {
          LabeledContent(sharedCause.label) {
            Text(sharedWith.map(\.name).formatted(.list(type: .and)))
          }
          .foregroundStyle(.orange)
        }
      } header: {
        Text(digest.name)
          .font(.title2.bold())
      }
      websitePick
      Section {
        VenuePlaceMap(
          geocodedLocation: geocodedLocation, pickedPlace: pickedPlace,
          pickedIdentifier: pickedIdentifier, suggestedPlace: suggestion?.place,
          candidates: candidates, selectedCandidate: $selectedCandidate,
          isPlacingPin: isPlacingPin, newPin: $newPin)
      }
      Section("Shows") {
        LabeledContent("Count", value: shows.count.formatted())
        if let first = shows.first {
          LabeledContent("First", value: first.date.formatted(.compact))
        }
        if let last = shows.last, shows.count > 1 {
          LabeledContent("Last", value: last.date.formatted(.compact))
        }
        if !headliners.isEmpty {
          LabeledContent("Headliners", value: headliners.formatted(.list(type: .and)))
        }
      }
      Section("Pick") {
        HStack {
          Text(pickDescription)
            #if !os(tvOS)
              .textSelection(.enabled)
            #endif
          #if !os(tvOS)
            if pickedIdentifier != nil {
              Spacer()
              PlaceCardButton(item: pickedPlace, identifier: pickedIdentifier)
            }
          #endif
        }
        if let pickedPlaceError {
          Label(
            "The picked place can't be found: \(pickedPlaceError.localizedDescription)",
            systemImage: "exclamationmark.triangle"
          )
          .foregroundStyle(.orange)
        }
        verification
        HStack {
          #if !os(tvOS)
            Toggle("Place a Pin", isOn: $isPlacingPin)
            Button("Use Pin") {
              if let newPin {
                pick = .coordinate(latitude: newPin.latitude, longitude: newPin.longitude)
                self.newPin = nil
                isPlacingPin = false
              }
            }
            .disabled(newPin == nil)
          #endif
          Button("No Place") { pick = .noPlace }
          Button("Clear") { pick = nil }
            .disabled(pick == nil)
        }
      }
      if let suggestion, let suggestedPick = suggestion.place.pick {
        Section("Suggested Place") {
          Text(
            [suggestion.place.name, suggestion.place.address].compactMap { $0 }
              .joined(separator: "\n")
          )
          Label(suggestion.confidence.label, systemImage: suggestion.confidence.systemImage)
            .foregroundStyle(suggestion.confidence.color)
          HStack {
            #if !os(tvOS)
              PlaceCardButton(identifier: suggestion.place.identifier)
            #endif
            Button("Use Suggestion") { pick = suggestedPick }
            Button("Dismiss") { suggestions[digest.venue.id]?.isDismissed = true }
          }
        }
      }
      Section {
        ForEach(candidates, id: \.identifier) { candidate in
          VenueCandidateRow(
            candidate: candidate, geocodedLocation: geocodedLocation,
            isPicked: candidate.identifier?.rawValue == pickedIdentifier,
            isSelected: candidate.identifier?.rawValue == selectedCandidate
          ) {
            if let candidatePick = FoundPlace(candidate).pick {
              pick = candidatePick
            }
          }
        }
        if hasSearched, !isSearching, candidates.isEmpty {
          Text("No places found.")
            .foregroundStyle(.secondary)
        }
      } header: {
        HStack {
          Text("Places in Maps")
          Spacer()
          if isSearching {
            ProgressView()
              .controlSize(.small)
          }
          Button(hasSearched ? "Search Again" : "Find Places") {
            Task { await findPlaces() }
          }
          .disabled(isSearching)
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle(digest.name)
    .task(id: pick) {
      await resolvePickedPlace()
    }
    // The places Maps has for the venue, so they're on the map without asking.
    .task {
      if !hasSearched { await findPlaces() }
    }
  }

  /// The address Maps gave, how it compares, and the accepted address.
  @ViewBuilder private var mapsAddress: some View {
    let venueAddress = address ?? VenueAddress(digest.location)
    let check = AddressCheck(venue: venueAddress, maps: model.venueMapsAddressMap[digest.id])
    if let address {
      LabeledContent("Accepted", value: address.formatted)
    }
    switch check {
    case .matches:
      Label("Matches Maps", systemImage: "checkmark.circle")
        .foregroundStyle(.green)
    case .differs(let found):
      LabeledContent("Maps") {
        Text(found.formatted)
          .foregroundStyle(.orange)
          #if !os(tvOS)
            .textSelection(.enabled)
          #endif
      }
      Button("Use Maps' Address") { address = found }
    case .unknown:
      Label("Not compared with Maps yet", systemImage: "questionmark.circle")
        .foregroundStyle(.secondary)
    }
    if address != nil {
      Button("Undo Accepted Address") { address = nil }
    }
  }

  /// The picked place's website in Maps.
  private var mapsWebsite: URL? { pickedPlace?.url }

  /// The website venuemap.txt gets: the pick, or the archive's when unpicked.
  private var chosenWebsite: URL? { website ?? digest.location.web }

  /// The websites the venue might have: the archive's, where it and Maps' end up, and Maps'.
  private var websiteCandidates: [URL] {
    let found = [digest.location.web, mapsWebsite].compactMap { $0 }
    let ended = found.map { url in
      checks.webCheck(venueID: digest.venue.id, url: url)?.finalURL(from: url)
        ?? WebCheck.loadable(url)
    }
    var seen = Set<URL>()
    return (found + ended).filter { seen.insert($0).inserted }
  }

  private var websiteDescription: String {
    website == nil ? String(localized: "Unpicked, so the archive's") : String(localized: "Picked")
  }

  @ViewBuilder private var websitePick: some View {
    Section("Website") {
      LabeledContent(websiteDescription) {
        if let chosenWebsite {
          Text(chosenWebsite.absoluteString)
            #if !os(tvOS)
              .textSelection(.enabled)
            #endif
        } else {
          Text("No website")
            .foregroundStyle(.secondary)
        }
      }
      if let chosenWebsite, checkingWebsites.contains(chosenWebsite) {
        ProgressView()
          .controlSize(.small)
      } else {
        ForEach(checks.websiteNotes(for: digest, pick: pick, web: chosenWebsite), id: \.self) {
          $0.label
        }
        if let chosenWebsite,
          let title = checks.webCheck(venueID: digest.venue.id, url: chosenWebsite)?.title
        {
          LabeledContent("Page Title", value: title)
        }
      }
      HStack {
        if let chosenWebsite {
          Button("Check Again") { Task { await checkWebsite(chosenWebsite) } }
            .disabled(checkingWebsites.contains(chosenWebsite))
        }
        Button("Clear") { website = nil }
          .disabled(website == nil)
      }
      #if !os(tvOS)
        .sheet(
          isPresented: Binding(
            get: { previewedWebsite != nil }, set: { if !$0 { previewedWebsite = nil } })
        ) {
          if let previewedWebsite {
            VenueWebsitePreview(url: previewedWebsite)
          }
        }
      #endif
    }
    Section("Websites") {
      ForEach(websiteCandidates, id: \.self) { url in
        VenueWebsiteRow(
          url: url, notes: candidateNotes(url),
          title: checks.webCheck(venueID: digest.venue.id, url: url)?.title,
          sources: sources(of: url), isChecking: checkingWebsites.contains(url),
          isPicked: website == url
        ) {
          // The app can't load http, so the preview shows the https version.
          previewedWebsite = WebCheck.loadable(url)
        } use: {
          website = url
        }
      }
      HStack {
        TextField("Other Website", text: $otherWebsite)
        Button("Use") {
          if let url = otherWebsiteURL {
            website = url
            otherWebsite = ""
          }
        }
        .disabled(otherWebsiteURL == nil)
      }
    }
    .task(id: websiteCandidates + [chosenWebsite].compactMap { $0 }) {
      for url in websiteCandidates + [chosenWebsite].compactMap({ $0 })
      where checks.webCheck(venueID: digest.venue.id, url: url) == nil {
        await checkWebsite(url)
      }
    }
  }

  /// A typed website, when it is a web URL.
  private var otherWebsiteURL: URL? {
    guard let url = URL(string: otherWebsite.trimmingCharacters(in: .whitespaces)),
      ["http", "https"].contains(url.scheme?.lowercased()), url.host() != nil
    else { return nil }
    return url
  }

  /// What checking the candidate found, without comparing it to Maps.
  private func candidateNotes(_ url: URL) -> [VenueWebsiteNote] {
    VenueWebsiteNote.notes(
      web: url, name: digest.name, webCheck: checks.webCheck(venueID: digest.venue.id, url: url),
      mapsWebsite: nil)
  }

  /// Where the candidate came from.
  private func sources(of url: URL) -> [String] {
    var sources = [String]()
    if url == digest.location.web { sources.append(String(localized: "Archive")) }
    if url == mapsWebsite { sources.append(String(localized: "Maps")) }
    if sources.isEmpty { sources.append(String(localized: "Where it ends up")) }
    return sources
  }

  private func checkWebsite(_ url: URL) async {
    guard checkingWebsites.insert(url).inserted else { return }
    await checks.checkWebsite(
      venue: digest.venue, url: url, isOwn: url == chosenWebsite)
    checkingWebsites.remove(url)
  }

  /// What verifying found for the pick.
  @ViewBuilder private var verification: some View {
    switch checks.verification(venue: digest.venue, pick: pick) {
    case .verified:
      Label("Verified in Maps", systemImage: "checkmark.seal.fill")
        .foregroundStyle(.green)
    case .replaced(let found):
      Label(
        "Maps now knows this place by another identifier.",
        systemImage: "exclamationmark.triangle"
      )
      .foregroundStyle(.orange)
      if let currentPick = found.pick {
        Button("Switch to Current Identifier") { pick = currentPick }
      }
    case .notFound:
      Label(
        "Maps can't find this place; it may have closed.", systemImage: "exclamationmark.triangle"
      )
      .foregroundStyle(.orange)
    case nil:
      EmptyView()
    }
  }

  private func findPlaces() async {
    isSearching = true
    defer {
      isSearching = false
      hasSearched = true
    }
    candidates = await VenueCandidateSearch(venue: digest.venue, location: geocodedLocation)
      .candidates()
  }

  /// Finds the pick, or the archive's place when unpicked, the way the app will, which checks that
  /// the identifier still resolves.
  private func resolvePickedPlace() async {
    pickedPlace = nil
    pickedPlaceError = nil
    let placemark = pick == nil ? digest.venue.mapKitID.map(Placemark.identifier) : pick?.placemark
    guard let placemark else { return }
    do {
      let place = try await placemark.mapItem(for: digest.venue)
      pickedPlace = place
      checks.noteMapsWebsite(venueID: digest.venue.id, url: place.url)
    } catch {
      pickedPlaceError = error
    }
  }
}

/// Its own view, so a batch updating the detail doesn't redraw the map.
private struct VenuePlaceMap: View {
  let geocodedLocation: CLLocation?
  let pickedPlace: MKMapItem?
  let pickedIdentifier: String?
  let suggestedPlace: FoundPlace?
  let candidates: [MKMapItem]
  @Binding var selectedCandidate: String?
  let isPlacingPin: Bool
  @Binding var newPin: CLLocationCoordinate2D?

  /// Fits every pin, again as more arrive.
  @State private var position = MapCameraPosition.automatic

  /// What's pinned, so the map can fit it when it changes.
  private var pinned: [String] {
    [
      geocodedLocation.map { "\($0.coordinate)" }, pickedPlace?.identifier?.rawValue,
      suggestedPlace?.identifier,
    ]
    .compactMap { $0 } + candidates.compactMap { $0.identifier?.rawValue }
  }

  /// The suggestion, unless the picked place or a candidate shows it already.
  private var suggestionIsShown: Bool {
    guard let identifier = suggestedPlace?.identifier else { return true }
    return identifier == pickedIdentifier
      || candidates.contains { $0.identifier?.rawValue == identifier }
  }

  /// The picked place, unless it is a candidate, which shows it already.
  private var pickedPlaceIsShown: Bool {
    guard let pickedIdentifier else { return false }
    return candidates.contains { $0.identifier?.rawValue == pickedIdentifier }
  }

  var body: some View {
    MapReader { proxy in
      Map(
        position: $position, interactionModes: VenuePlaces.mapInteractionModes,
        selection: $selectedCandidate
      ) {
        if let geocodedLocation {
          Marker("Geocoded", systemImage: "scope", coordinate: geocodedLocation.coordinate)
            .tint(.gray)
        }
        if let pickedPlace, !pickedPlaceIsShown {
          Marker(item: pickedPlace)
            .tint(.green)
        }
        if let suggestedPlace, !suggestionIsShown {
          Marker(
            suggestedPlace.name ?? String(localized: "Suggested"),
            systemImage: "sparkle.magnifyingglass", coordinate: suggestedPlace.location.coordinate
          )
          .tint(.orange)
        }
        if let newPin {
          Marker("New Pin", systemImage: "mappin", coordinate: newPin)
            .tint(.orange)
        }
        ForEach(candidates, id: \.identifier) { candidate in
          if let identifier = candidate.identifier?.rawValue {
            Marker(item: candidate)
              .tint(identifier == pickedIdentifier ? .green : .accentColor)
              .tag(identifier)
          }
        }
      }
      #if !os(tvOS)
        // Only while placing a pin, so clicks otherwise still choose markers.
        .gesture(
          SpatialTapGesture().onEnded { newPin = proxy.convert($0.location, from: .local) },
          isEnabled: isPlacingPin)
      #endif
      .venuePlacesMap()
      .onChange(of: pinned) { position = .automatic }
    }
    .frame(minHeight: 300)
  }
}

/// A place in Maps a venue might be, with how far it is from where the venue geocodes.
private struct VenueCandidateRow: View {
  let candidate: MKMapItem
  let geocodedLocation: CLLocation?
  let isPicked: Bool
  let isSelected: Bool
  let use: () -> Void

  private var distance: String? {
    guard let geocodedLocation else { return nil }
    let meters = candidate.location.distance(from: geocodedLocation)
    return Measurement(value: meters, unit: UnitLength.meters)
      .formatted(.measurement(width: .abbreviated, usage: .road))
  }

  private var details: String {
    [candidate.categoryName, distance].compactMap { $0 }.joined(separator: " · ")
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(candidate.name ?? String(localized: "Unnamed Place"))
          .fontWeight(isSelected ? .bold : .regular)
        if let address = candidate.singleLineAddress {
          Text(address)
            .font(.caption)
        }
        if !details.isEmpty {
          Text(details)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
      #if !os(tvOS)
        PlaceCardButton(item: candidate)
      #endif
      if isPicked {
        Label("Picked", systemImage: "checkmark.circle.fill")
          .labelStyle(.iconOnly)
          .foregroundStyle(.green)
      } else {
        Button("Use This Place", action: use)
      }
    }
  }
}

/// A website the venue might have, with what checking it found.
private struct VenueWebsiteRow: View {
  let url: URL
  let notes: [VenueWebsiteNote]
  let title: String?
  let sources: [String]
  let isChecking: Bool
  let isPicked: Bool
  let preview: () -> Void
  let use: () -> Void

  private var details: String {
    ([sources.formatted(.list(type: .and))] + [title].compactMap { $0 }).joined(separator: " · ")
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(url.absoluteString)
          #if !os(tvOS)
            .textSelection(.enabled)
          #endif
        Text(details)
          .font(.caption)
          .foregroundStyle(.secondary)
        if let worst = notes.first, worst.severity > .good {
          Text(worst.text)
            .font(.caption)
            .foregroundStyle(worst.severity.color)
        }
      }
      Spacer()
      if isChecking {
        ProgressView()
          .controlSize(.small)
      } else if let worst = notes.first {
        Image(systemName: worst.systemImage)
          .foregroundStyle(worst.severity.color)
          .help(notes.map(\.text).joined(separator: "\n"))
      }
      #if !os(tvOS)
        Button("Preview", action: preview)
      #endif
      if isPicked {
        Label("Picked", systemImage: "checkmark.circle.fill")
          .labelStyle(.iconOnly)
          .foregroundStyle(.green)
      } else {
        Button("Use This Website", action: use)
      }
    }
  }
}
