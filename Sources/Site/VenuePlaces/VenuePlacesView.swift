//
//  VenuePlacesView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import Shared
import SwiftUI

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

/// The gate, then the venues once the archive has loaded.
struct VenuePlacesView: View {
  let model: SiteModel

  @State private var store = VenuePickStore()

  var body: some View {
    if !VenuePlaces.isEnabled {
      ContentUnavailableView("Venue Places is only in Debug builds on macOS.", systemImage: "map")
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

struct VenuePlacesSplitView: View {
  @Environment(VaultModel.self) private var model
  let store: VenuePickStore

  @State private var digests: [VenueDigest] = []
  @State private var selection: ArchivePath?
  @State private var filter = VenuePlacesFilter.all
  @State private var searchString = ""

  private var shownDigests: [VenueDigest] {
    digests.filter { digest in
      filter.includes(digest, pick: store[digest.venue.id])
        && (searchString.isEmpty || digest.name.localizedStandardContains(searchString))
    }
  }

  private var selectedDigest: VenueDigest? {
    digests.first { $0.id == selection }
  }

  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        Section("All Venues") {
          ForEach(shownDigests) { digest in
            VenuePlaceRow(digest: digest, status: VenuePickStatus(store[digest.venue.id]))
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
      if let selectedDigest {
        VenuePlaceDetail(
          digest: selectedDigest,
          pick: Binding(
            get: { store[selectedDigest.venue.id] },
            set: { store[selectedDigest.venue.id] = $0 }))
      } else {
        ContentUnavailableView("Choose a Venue", systemImage: "mappin.and.ellipse")
      }
    }
    .toolbar {
      Picker("Filter", selection: $filter) {
        ForEach(VenuePlacesFilter.allCases, id: \.self) {
          Text($0.label)
        }
      }
      .pickerStyle(.segmented)
      Button("Copy JSON", systemImage: "doc.on.doc") {
        copyToPasteboard(store.json)
      }
    }
    .overlay(alignment: .bottom) {
      if let readError = store.readError {
        Text("The saved picks can't be read, so changes aren't saved: \(readError.localizedDescription)")
          .padding()
          .background(.red.opacity(0.2), in: .rect(cornerRadius: 8))
          .padding()
      }
    }
    .task(id: ObjectIdentifier(model)) {
      digests = model.vault.orderedVenueIDs.compactMap { model.vault.digest(venue: $0) }
    }
  }

  private func copyToPasteboard(_ string: String) {
    #if canImport(AppKit)
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(string, forType: .string)
    #elseif canImport(UIKit) && !os(tvOS)
      UIPasteboard.general.string = string
    #endif
  }
}

private struct VenuePlaceRow: View {
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
