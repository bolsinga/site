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

  func accept(_ found: VenueAddress, for venue: Venue) {
    self[venue.id] = .accepting(found, for: venue)
  }
}

extension VenueAddress {
  /// Maps' address made the venue's, keeping the venue's street when Maps found none.
  static func accepting(_ found: VenueAddress, for venue: Venue) -> VenueAddress {
    VenueAddress(
      street: found.street ?? venue.location.street, city: found.city, state: found.state)
  }
}

extension AddressCheck {
  /// The address Maps gave, when it differs.
  var differingAddress: (VenueAddress, Set<Part>)? {
    guard case .differs(let found, let parts) = self else { return nil }
    return (found, parts)
  }

  var foundOnlyCity: Bool {
    if case .onlyCityFound = self { true } else { false }
  }
}

extension VenueAddress {
  /// The address on one line, with the parts emphasized.
  func highlighted(_ parts: Set<AddressCheck.Part>) -> AttributedString {
    func part(_ string: String, _ part: AddressCheck.Part) -> AttributedString {
      var text = AttributedString(string)
      if parts.contains(part) {
        text.foregroundColor = .orange
        text.inlinePresentationIntent = .stronglyEmphasized
      }
      return text
    }
    var text = AttributedString()
    if let street {
      text += part(street, .street) + AttributedString(", ")
    }
    return text + part(city, .city) + AttributedString(", ") + part(state, .state)
  }
}

/// What the tools found across every venue, to verify and accept.
struct VenuePlacesDashboard: View {
  @Environment(VaultModel.self) private var model

  let digests: [VenueDigest]
  let addresses: VenueAddressPickStore
  let open: (ArchivePath) -> Void

  @State private var isConfirmingUseAll = false

  private func check(_ digest: VenueDigest) -> AddressCheck {
    AddressCheck(
      venue: addresses.address(for: digest.venue), maps: model.venueMapsAddressMap[digest.id])
  }

  var body: some View {
    let checks = digests.map { (digest: $0, check: check($0)) }
    let differing = checks.compactMap { item in
      item.check.differingAddress.map { (digest: item.digest, found: $0.0, parts: $0.1) }
    }
    let onlyCity = checks.filter { $0.check.foundOnlyCity }.map(\.digest)
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
            found: item.found, parts: item.parts
          ) {
            open(item.digest.id)
          } use: {
            addresses.accept(item.found, for: item.digest.venue)
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
            addresses.accept(item.found, for: item.digest.venue)
          }
        }
      } message: {
        Text("Each can be undone under Accepted Addresses.")
      }
      if !onlyCity.isEmpty {
        Section("Maps Found Only the City (\(onlyCity.count))") {
          ForEach(onlyCity) { digest in
            VenueSummaryRow(digest: digest, detail: digest.location.addressString) {
              open(digest.id)
            }
          }
        }
      }
      if !accepted.isEmpty {
        Section("Accepted Addresses (\(accepted.count))") {
          ForEach(accepted) { digest in
            VenueSummaryRow(
              digest: digest, detail: addresses.address(for: digest.venue).formatted
            ) {
              open(digest.id)
            } undo: {
              addresses[digest.venue.id] = nil
            }
          }
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Dashboard")
  }
}

/// A venue whose address differs from Maps', with both and the parts that differ.
private struct VenueAddressRow: View {
  let digest: VenueDigest
  let venue: VenueAddress
  let found: VenueAddress
  let parts: Set<AddressCheck.Part>
  let show: () -> Void
  let use: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(digest.name)
        Text("Venue: \(venue.highlighted(parts))")
          .font(.caption)
        Text("Maps: \(found.highlighted(parts))")
          .font(.caption)
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

/// A venue with a line about it, a way to show it, and maybe a way to undo what was done.
private struct VenueSummaryRow: View {
  let digest: VenueDigest
  let detail: String
  let show: () -> Void
  var undo: (() -> Void)? = nil

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
      if let undo {
        Button("Undo", action: undo)
      }
    }
  }
}
