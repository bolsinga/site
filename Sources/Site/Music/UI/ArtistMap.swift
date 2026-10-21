//
//  ArtistMap.swift
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

struct ArtistMap: View {
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
