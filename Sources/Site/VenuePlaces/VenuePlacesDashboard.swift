//
//  VenuePlacesDashboard.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/26.
//

import Shared
import SwiftUI

extension VenueAddressPickStore {
  /// The address the venue has: the accepted one, or the archive's.
  func address(for venue: Venue) -> VenueAddress {
    self[venue.id] ?? VenueAddress(venue.location)
  }
}

extension AddressCheck {
  /// The address Maps gave, when it differs.
  var differingAddress: VenueAddress? {
    guard case .differs(let found) = self else { return nil }
    return found
  }
}

extension SuggestionConfidence {
  var label: LocalizedStringResource {
    switch self {
    case .strong: "Strong match"
    case .medium: "Likely match"
    case .weak: "Weak match"
    }
  }

  var systemImage: String {
    switch self {
    case .strong: "checkmark.circle.fill"
    case .medium: "circle.lefthalf.filled"
    case .weak: "questionmark.circle"
    }
  }

  var color: Color {
    switch self {
    case .strong: .green
    case .medium: .orange
    case .weak: .secondary
    }
  }
}

/// What the tools found across every venue, to verify and accept.
struct VenuePlacesDashboard: View {
  @Environment(VaultModel.self) private var model
  @Environment(VenueSuggestionStore.self) private var suggestions

  let digests: [VenueDigest]
  let store: VenuePickStore
  let addresses: VenueAddressPickStore
  let open: (ArchivePath) -> Void

  @State private var isConfirmingUseAll = false
  @State private var isConfirmingUseStrong = false

  private typealias Suggested = (
    digest: VenueDigest, place: FoundPlace, confidence: SuggestionConfidence
  )

  /// Venues without a place that Maps suggested one for, most likely first.
  private var suggested: [Suggested] {
    digests.compactMap { digest in
      guard store[digest.venue.id] == nil, digest.venue.mapKitID == nil,
        let offered = suggestions[digest.venue.id]?.offered
      else { return nil }
      return (digest, offered.place, offered.confidence)
    }
    .sorted { $0.confidence > $1.confidence }
  }

  /// Venues without a place that Maps found nothing likely for.
  private var unfound: [VenueDigest] {
    digests.filter { digest in
      guard store[digest.venue.id] == nil, digest.venue.mapKitID == nil,
        let suggestion = suggestions[digest.venue.id]
      else { return false }
      return suggestion.place == nil
    }
  }

  private func check(_ digest: VenueDigest) -> AddressCheck {
    AddressCheck(
      venue: addresses.address(for: digest.venue), maps: model.venueMapsAddressMap[digest.id])
  }

  var body: some View {
    let checks = digests.map { (digest: $0, check: check($0)) }
    let differing = checks.compactMap { item in
      item.check.differingAddress.map { (digest: item.digest, found: $0) }
    }
    let accepted = digests.filter { addresses[$0.venue.id] != nil }

    Form {
      if model.geocodingInProgress {
        Section {
          ProgressView(value: model.geocodingProgress) {
            Text("Geocoding Venues")
          } currentValueLabel: {
            Text("Venues are compared as Maps finds them.")
          }
        }
      }
      Section {
        if differing.isEmpty {
          Text("Every address matches Maps.")
            .foregroundStyle(.secondary)
        }
        ForEach(differing, id: \.digest.id) { item in
          VenueAddressRow(
            digest: item.digest, venue: addresses.address(for: item.digest.venue),
            found: item.found
          ) {
            open(item.digest.id)
          } use: {
            addresses[item.digest.venue.id] = item.found
          }
        }
      } header: {
        HStack {
          Text("Address Doesn't Match Maps (\(differing.count))")
          Spacer()
          Button("Use All Maps Addresses") { isConfirmingUseAll = true }
            .disabled(differing.isEmpty)
        }
      }
      .confirmationDialog(
        "Use Maps' Address for \(differing.count) Venues?", isPresented: $isConfirmingUseAll,
        titleVisibility: .visible
      ) {
        Button("Use All Maps Addresses") {
          for item in differing {
            addresses[item.digest.venue.id] = item.found
          }
        }
      } message: {
        Text("Each can be undone under Accepted Addresses.")
      }
      suggestedSection
      if !unfound.isEmpty {
        Section("No Place Found (\(unfound.count))") {
          ForEach(unfound) { digest in
            VenueSummaryRow(
              digest: digest, detail: digest.location.addressString, actionTitle: "No Place"
            ) {
              open(digest.id)
            } action: {
              store[digest.venue.id] = .noPlace
            }
          }
        }
      }
      if !accepted.isEmpty {
        Section("Accepted Addresses (\(accepted.count))") {
          ForEach(accepted) { digest in
            VenueSummaryRow(
              digest: digest, detail: addresses.address(for: digest.venue).formatted,
              actionTitle: "Undo"
            ) {
              open(digest.id)
            } action: {
              addresses[digest.venue.id] = nil
            }
          }
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Dashboard")
  }

  @ViewBuilder private var suggestedSection: some View {
    let suggested = suggested
    let strong = suggested.filter { $0.confidence == .strong }
    if !suggested.isEmpty {
      Section {
        ForEach(suggested, id: \.digest.id) { item in
          SuggestedPlaceRow(digest: item.digest, place: item.place, confidence: item.confidence) {
            open(item.digest.id)
          } use: {
            store[item.digest.venue.id] = item.place.pick
          } dismiss: {
            suggestions[item.digest.venue.id]?.isDismissed = true
          }
        }
      } header: {
        HStack {
          Text("Suggested Places (\(suggested.count))")
          Spacer()
          Button("Use All Strong Matches (\(strong.count))") { isConfirmingUseStrong = true }
            .disabled(strong.isEmpty)
        }
      }
      .confirmationDialog(
        "Use \(strong.count) Strong Matches?", isPresented: $isConfirmingUseStrong,
        titleVisibility: .visible
      ) {
        Button("Use All Strong Matches") {
          for item in strong {
            store[item.digest.venue.id] = item.place.pick
          }
        }
      } message: {
        Text("Each becomes the venue's pick, which can be cleared on its page.")
      }
    }
  }
}

/// A venue without a place, with the place Maps suggested and how likely it is.
private struct SuggestedPlaceRow: View {
  let digest: VenueDigest
  let place: FoundPlace
  let confidence: SuggestionConfidence
  let show: () -> Void
  let use: () -> Void
  let dismiss: () -> Void

  var body: some View {
    HStack {
      Image(systemName: confidence.systemImage)
        .foregroundStyle(confidence.color)
        .help(Text(confidence.label))
      VStack(alignment: .leading) {
        Text(digest.name)
        Text("Venue: \(digest.location.addressString.replacing("\n", with: ", "))")
          .font(.caption)
        Text("Maps: \([place.name, place.address].compactMap { $0 }.joined(separator: ", "))")
          .font(.caption)
          .foregroundStyle(confidence.color)
      }
      #if !os(tvOS)
        .textSelection(.enabled)
      #endif
      Spacer()
      #if !os(tvOS)
        PlaceCardButton(identifier: place.identifier)
      #endif
      Button("Show", action: show)
      Button("Dismiss", action: dismiss)
      Button("Use This Place", action: use)
    }
  }
}

/// A venue whose address differs from Maps', with both.
private struct VenueAddressRow: View {
  let digest: VenueDigest
  let venue: VenueAddress
  let found: VenueAddress
  let show: () -> Void
  let use: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(digest.name)
        Text("Venue: \(venue.formatted)")
          .font(.caption)
        Text("Maps: \(found.formatted)")
          .font(.caption)
          .foregroundStyle(.orange)
      }
      #if !os(tvOS)
        .textSelection(.enabled)
      #endif
      Spacer()
      Button("Show", action: show)
      Button("Use Maps' Address", action: use)
    }
  }
}

/// A venue with a line about it, a way to show it, and something to do about it.
private struct VenueSummaryRow: View {
  let digest: VenueDigest
  let detail: String
  let actionTitle: LocalizedStringResource
  let show: () -> Void
  let action: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(digest.name)
        Text(detail)
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Button("Show", action: show)
      Button(actionTitle, action: action)
    }
  }
}
