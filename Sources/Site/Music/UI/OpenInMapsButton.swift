//
//  OpenInMapsButton.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/4/26.
//

import MapKit
import Shared
import SwiftUI
import os

extension Logger {
  fileprivate static let openInMaps = Logger(category: "openInMaps")
}

/// Opens a venue in Maps: its place card when it has a MapKit identifier, otherwise a pin where it geocoded.
struct OpenInMapsButton: View {
  let venue: Venue
  /// Where the venue was placed on the app's maps.
  let mapItem: MKMapItem?

  /// A lookup can wait behind the venues being placed at launch, so further taps are ignored.
  @State private var isOpening = false

  var body: some View {
    if isOpening {
      ProgressView()
    } else {
      Button("Open in Maps", systemImage: "map") {
        isOpening = true
        Task {
          await open()
          isOpening = false
        }
      }
      .disabled(mapItem == nil && venue.mapKitID == nil)
    }
  }

  private func open() async {
    if let mapKitID = venue.mapKitID, let identifier = MKMapItem.Identifier(rawValue: mapKitID) {
      do {
        show(try await MapItemLookup.mapItem(for: identifier))
        return
      } catch {
        Logger.openInMaps.error(
          "\(venue.id, privacy: .public) - \(mapKitID, privacy: .public): \(error, privacy: .public)"
        )
      }
    }
    if let mapItem { show(mapItem) }
  }

  private func show(_ item: MKMapItem) {
    #if !os(tvOS)
      item.openInMaps()
    #endif
  }
}
