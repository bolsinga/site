//
//  VenueBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 10/26/26.
//

import MapKit
import Shared
import SwiftUI

/// The map runs edge to edge under the toolbar, fading into the background where the venue's name and address sit.
private struct VenueMapHeader: View {
  @Environment(VaultModel.self) private var model

  let digest: VenueDigest?

  @State private var mapItem: MKMapItem?

  var body: some View {
    LocationMap(geocodingInProgress: model.geocodingInProgress, item: $mapItem, minHeight: 0)
      .containerRelativeFrame(.vertical) { height, _ in height * 0.45 }
      .mask(
        LinearGradient(
          stops: [.init(color: .black, location: 0.6), .init(color: .clear, location: 1)],
          startPoint: .top, endPoint: .bottom)
      )
      .overlay(alignment: .bottomLeading) {
        if let digest {
          VStack(alignment: .leading) {
            Text(digest.name)
              .font(.largeTitle.bold())
            AddressView(location: digest.location)
              .foregroundStyle(.secondary)
          }
          .padding(.horizontal)
        }
      }
      .onAppear {
        mapItem = digest.flatMap { model.venueMapItemMap[$0.id] }
      }
      .onChange(of: model.venueMapItemMap) { _, newValue in
        mapItem = digest.flatMap { newValue[$0.id] }
      }
      // Paging keeps this header, so it follows the venue shown.
      .onChange(of: digest?.id) {
        mapItem = digest.flatMap { model.venueMapItemMap[$0.id] }
      }
  }
}

/// A venue's details that can be paged to the previous and next venue, in library order.
struct VenueBrowser: View {
  let id: ArchivePath
  let venueIDs: [ArchivePath]
  let digest: (ArchivePath) -> VenueDigest?
  let url: (VenueDigest) -> URL?
  let isPathNavigable: (ArchivePath) -> Bool
  /// Called with the venue the pager settles on, so the navigation path names the venue shown.
  let didShow: (ArchivePath) -> Void

  var body: some View {
    PagedBrowser(
      item: id, neighbors: { venueIDs.wrappingNeighbors(of: $0) }, digest: digest, url: url,
      title: { _, digest in digest?.name ?? "" }, didShow: didShow
    ) { _, digest in
      VenueMapHeader(digest: digest)
    } page: { digest, bottomContentMargin in
      VenueDetail(
        digest: digest, isPathNavigable: isPathNavigable,
        bottomContentMargin: bottomContentMargin)
    }
  }
}
