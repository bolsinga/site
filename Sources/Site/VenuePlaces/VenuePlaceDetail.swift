//
//  VenuePlaceDetail.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import MapKit
import Shared
import SwiftUI

/// A venue's address, show history, the places in Maps it might be, and its pick.
struct VenuePlaceDetail: View {
  @Environment(VaultModel.self) private var model
  @Environment(VenuePlaceChecks.self) private var checks

  let digest: VenueDigest
  @Binding var pick: VenuePick?

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

  private var suggestion: FoundPlace? {
    pick == nil ? checks.suggestions[digest.venue.id] : nil
  }

  private var pickedIdentifier: String? {
    guard case .place(let identifier, _) = pick else { return nil }
    return identifier
  }

  private var pickDescription: String {
    switch pick {
    case nil: String(localized: "Unpicked")
    case .place(let identifier, let address):
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
      } header: {
        Text(digest.name)
          .font(.title2.bold())
      }
      Section {
        VenuePlaceMap(
          geocodedLocation: geocodedLocation, pickedPlace: pickedPlace,
          pickedIdentifier: pickedIdentifier, candidates: candidates,
          selectedCandidate: $selectedCandidate, isPlacingPin: isPlacingPin, newPin: $newPin)
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
        Text(pickDescription)
          #if !os(tvOS)
            .textSelection(.enabled)
          #endif
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
      if let suggestion, let suggestedPick = suggestion.pick {
        Section("Auto-match Suggestion") {
          Text(
            [suggestion.name, suggestion.address].compactMap { $0 }.joined(separator: "\n")
          )
          HStack {
            Button("Use Suggestion") { pick = suggestedPick }
            Button("Dismiss") { checks.dismissSuggestion(venueID: digest.venue.id) }
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
            if let identifier = candidate.identifier?.rawValue {
              pick = .place(identifier: identifier, address: candidate.singleLineAddress)
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
  }

  /// What Verify All found for the pick.
  @ViewBuilder private var verification: some View {
    switch checks.verification(venueID: digest.venue.id, pick: pick) {
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

  /// Finds the pick the way the app will, which checks that a picked identifier still resolves.
  private func resolvePickedPlace() async {
    pickedPlace = nil
    pickedPlaceError = nil
    guard let placemark = pick?.placemark else { return }
    do {
      pickedPlace = try await placemark.mapItem(for: digest.venue)
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
  let candidates: [MKMapItem]
  @Binding var selectedCandidate: String?
  let isPlacingPin: Bool
  @Binding var newPin: CLLocationCoordinate2D?

  /// The picked place, unless it is a candidate, which shows it already.
  private var pickedPlaceIsShown: Bool {
    guard let pickedIdentifier else { return false }
    return candidates.contains { $0.identifier?.rawValue == pickedIdentifier }
  }

  var body: some View {
    MapReader { proxy in
      Map(selection: $selectedCandidate) {
        if let geocodedLocation {
          Marker("Geocoded", systemImage: "scope", coordinate: geocodedLocation.coordinate)
            .tint(.gray)
        }
        if let pickedPlace, !pickedPlaceIsShown {
          Marker(item: pickedPlace)
            .tint(.green)
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

  @State private var showsCard = false

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
        Button("Place Card", systemImage: "info.circle") { showsCard = true }
          .labelStyle(.iconOnly)
          .buttonStyle(.borderless)
          .mapItemDetailPopover(isPresented: $showsCard, item: candidate)
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
