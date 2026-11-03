//
//  SharedLocationDetail.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/3/26.
//

import MapKit
import Shared
import SwiftUI

/// The point a group of venues shares, with the venues, each opening its detail.
struct SharedLocationDetail: View {
  let sharedLocation: SharedLocation
  let digests: [VenueDigest]
  let store: VenuePickStore

  /// How far around the point the map shows.
  private static var span: CLLocationDistance { 3_000 }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Map(
          initialPosition: .region(
            MKCoordinateRegion(
              center: sharedLocation.coordinate, latitudinalMeters: Self.span,
              longitudinalMeters: Self.span))
        ) {
          Marker(
            String(localized: "\(sharedLocation.venues.count) Venues"),
            coordinate: sharedLocation.coordinate)
        }
        .frame(minHeight: 240)
        List {
          Section {
            ForEach(digests) { digest in
              NavigationLink(value: digest.id) {
                VenuePlaceRow(digest: digest, status: VenuePickStatus(store[digest.venue.id]))
              }
            }
          } header: {
            Text(sharedLocation.cause.label)
          }
        }
      }
      .navigationDestination(for: ArchivePath.self) { id in
        if let digest = digests.first(where: { $0.id == id }) {
          VenuePlaceDetail(digest: digest, pick: store.binding(for: digest.venue.id))
        }
      }
    }
  }
}
