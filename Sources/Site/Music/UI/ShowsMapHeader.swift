//
//  ShowsMapHeader.swift
//
//
//  Created by Greg Bolsinga on 10/21/26.
//

import MapKit
import Shared
import SwiftUI

private struct VenuePlace: Identifiable {
  let id: ArchivePath
  let coordinate: CLLocationCoordinate2D
}

private let dotSize: CGFloat = 14

private struct VenueDot: View {
  var body: some View {
    Circle()
      .fill(Color.accentColor)
      .overlay(Circle().stroke(.white, lineWidth: 1.5))
      .frame(width: dotSize, height: dotSize)
  }
}

struct ShowsMap: View {
  @Environment(VaultModel.self) private var model

  let shows: [ShowDigest]

  private var places: [VenuePlace] {
    var seen = Set<ArchivePath>()
    return shows.compactMap { show in
      guard seen.insert(show.venueID).inserted,
        let mapItem = model.venueMapItemMap[show.venueID]
      else { return nil }
      return VenuePlace(id: show.venueID, coordinate: mapItem.location.coordinate)
    }
  }

  var body: some View {
    let places = places
    ZStack {
      if !places.isEmpty {
        ClusterMap(
          items: places, anchorY: dotSize / 2.0, animatesFit: false,
          fitZoomOutFactor: detailMapFitZoomOutFactor, clustersItems: false, isSubdued: true
        ) {
          Details(coordinate: $0.coordinate, title: "")
        } onSelect: { _ in
        } clusterLabel: {
          String(localized: "Cluster, \($0) venues")
        } itemContent: { _ in
          VenueDot()
        } itemTitle: { _ in
          EmptyView()
        } clusterContent: {
          CategoryAnnotationView(category: .venues, render: .badge($0))
        }
        .allowsHitTesting(false)
      } else if model.geocodingInProgress {
        ProgressView()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

/// A map of the venues of some shows that fades into the page, with a title over the fade.
struct ShowsMapHeader: View {
  let shows: [ShowDigest]
  let title: String

  var body: some View {
    ShowsMap(shows: shows)
      .containerRelativeFrame(.vertical) { height, _ in height * 0.45 }
      .mask(
        LinearGradient(
          stops: [.init(color: .black, location: 0.6), .init(color: .clear, location: 1)],
          startPoint: .top, endPoint: .bottom)
      )
      .overlay(alignment: .bottomLeading) {
        Text(title)
          .font(.largeTitle.bold())
          .padding(.horizontal)
      }
  }
}

/// Lets a page's content run under the toolbar when it has a map header; otherwise the title goes in the navigation bar.
struct MapHeaderStyle: ViewModifier {
  let hasMap: Bool
  let title: String

  func body(content: Content) -> some View {
    if hasMap {
      content
        .ignoresSafeArea(edges: .top)
        #if os(macOS)
          .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        #else
          .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        #endif
        #if !os(tvOS)
          .toolbar(removing: .title)
        #endif
    } else {
      content
        .navigationTitle(title)
        #if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
        #endif
    }
  }
}
