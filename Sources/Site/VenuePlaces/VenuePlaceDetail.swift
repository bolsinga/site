//
//  VenuePlaceDetail.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Shared
import SwiftUI

/// A venue's address and show history, to help recall where it was, and its pick.
struct VenuePlaceDetail: View {
  let digest: VenueDigest
  @Binding var pick: VenuePick?

  private static var headlinerCount: Int { 5 }

  private var shows: [ShowDigest] { digest.shows.sorted() }

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

  private var pickDescription: String {
    switch pick {
    case nil: String(localized: "Unpicked")
    case .place(let identifier): String(localized: "Place: \(identifier)")
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
        HStack {
          Button("No Place") { pick = .noPlace }
          Button("Clear") { pick = nil }
            .disabled(pick == nil)
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle(digest.name)
  }
}
