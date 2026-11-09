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
  @Environment(VenuePlaceChecks.self) private var checks
  @Environment(VenueSuggestionStore.self) private var suggestions
  let sharedLocation: SharedLocation
  let digests: [VenueDigest]
  let store: VenuePickStore
  let addresses: VenueAddressPickStore

  /// Where each picked venue is, found the way the app finds a venue.
  @State private var pickedPlaces: [ArchivePath: MKMapItem] = [:]

  /// How far around the point the map shows.
  private static var span: CLLocationDistance { 3_000 }

  private var picks: [VenuePick?] { digests.map { store[$0.venue.id] } }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Map(
          initialPosition: .region(
            MKCoordinateRegion(
              center: sharedLocation.coordinate, latitudinalMeters: Self.span,
              longitudinalMeters: Self.span)),
          interactionModes: VenuePlaces.mapInteractionModes
        ) {
          Marker(
            String(localized: "\(sharedLocation.venues.count) Venues"),
            coordinate: sharedLocation.coordinate)
          ForEach(digests) { digest in
            if let place = pickedPlaces[digest.id] {
              Marker(digest.name, coordinate: place.location.coordinate)
                .tint(.green)
            }
          }
        }
        .venuePlacesMap()
        .frame(minHeight: 240)
        List {
          Section {
            ForEach(digests) { digest in
              NavigationLink(value: digest.id) {
                VenuePlaceRow(
                  digest: digest,
                  status: checks.status(
                    venue: digest.venue, pick: store[digest.venue.id],
                    suggestion: suggestions[digest.venue.id]))
              }
            }
          } header: {
            Text(sharedLocation.cause.label)
          }
        }
      }
      .navigationDestination(for: ArchivePath.self) { id in
        if let digest = digests.first(where: { $0.id == id }) {
          VenuePlaceDetail(
            digest: digest, pick: store.binding(for: digest.venue.id),
            address: addresses.binding(for: digest.venue.id))
        }
      }
    }
    .task(id: picks) {
      await resolvePickedPlaces()
    }
  }

  /// Picks that can't be found are left off the map; the venue's own detail says why.
  private func resolvePickedPlaces() async {
    var places = [ArchivePath: MKMapItem]()
    for digest in digests {
      guard let placemark = store[digest.venue.id]?.placemark else { continue }
      places[digest.id] = try? await placemark.mapItem(for: digest.venue)
    }
    pickedPlaces = places
  }
}
