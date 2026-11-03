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

  let digest: VenueDigest
  @Binding var pick: VenuePick?

  @State private var candidates: [MKMapItem] = []
  @State private var isSearching = false
  @State private var hasSearched = false
  @State private var selectedCandidate: String?
  /// The place picked before, found again from its identifier.
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

  @ViewBuilder private var map: some View {
    Map(selection: $selectedCandidate) {
      if let geocodedLocation {
        Marker("Geocoded", systemImage: "scope", coordinate: geocodedLocation.coordinate)
          .tint(.gray)
      }
      if let pickedPlace, let pickedIdentifier,
        !candidates.contains(where: { $0.identifier?.rawValue == pickedIdentifier })
      {
        Marker(item: pickedPlace)
          .tint(.green)
          .tag(pickedIdentifier)
      }
      ForEach(candidates, id: \.identifier) { candidate in
        if let identifier = candidate.identifier?.rawValue {
          Marker(item: candidate)
            .tint(identifier == pickedIdentifier ? .green : .accentColor)
            .tag(identifier)
        }
      }
    }
    .frame(minHeight: 300)
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
        map
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
        HStack {
          Button("No Place") { pick = .noPlace }
          Button("Clear") { pick = nil }
            .disabled(pick == nil)
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
    .task(id: pickedIdentifier) {
      await resolvePickedPlace()
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

  /// Finds the picked place again, which checks that its identifier still resolves.
  private func resolvePickedPlace() async {
    pickedPlace = nil
    pickedPlaceError = nil
    guard let pickedIdentifier else { return }
    do {
      // The same lookup the app makes for a venue whose place is known.
      pickedPlace = try await Placemark.identifier(pickedIdentifier).mapItem(for: digest.venue)
    } catch {
      pickedPlaceError = error
    }
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
