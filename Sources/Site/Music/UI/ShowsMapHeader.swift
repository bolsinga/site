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

/// Where the header's map is fully shown, from the top, before it fades into the page.
private let clearFraction = 0.6
private let fadeFraction = 1.0 - clearFraction

/// A day's venues are spread across the country; fit them closer than a detail map does.
private let dayMapFitZoomOutFactor = 1.3

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
  /// Keeps the map when there are no shows, and glides and fades as the shows change.
  var animatesChanges = false

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
      if !places.isEmpty || animatesChanges {
        ClusterMap(
          items: places, anchorY: dotSize / 2.0, animatesFit: animatesChanges,
          fitZoomOutFactor: animatesChanges ? dayMapFitZoomOutFactor : detailMapFitZoomOutFactor,
          isSubdued: true,
          animatesItems: animatesChanges, fitBottomFraction: animatesChanges ? fadeFraction : 0.0
        ) {
          Details(coordinate: $0.coordinate, title: "")
        } onSelect: { _ in
        } clusterLabel: {
          String(localized: "Cluster, \($0) venues")
        } itemContent: { _ in
          VenueDot()
        } itemTitle: { _ in
          EmptyView()
        } clusterContent: { _ in
          // Dots that are close together show as one, with no count.
          VenueDot()
        }
        .allowsHitTesting(false)
        // A kept map with no dots would show the last day's area, so it nearly fades out.
        .opacity(places.isEmpty ? 0.3 : 1)
        .animation(.default, value: places.isEmpty)
      }
      if places.isEmpty && model.geocodingInProgress {
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
  var animatesChanges = false

  var body: some View {
    ShowsMap(shows: shows, animatesChanges: animatesChanges)
      .containerRelativeFrame(.vertical) { height, _ in height * 0.45 }
      .mask(
        LinearGradient(
          stops: [
            .init(color: .black, location: clearFraction), .init(color: .clear, location: 1),
          ],
          startPoint: .top, endPoint: .bottom)
      )
      .overlay(alignment: .bottomLeading) {
        Text(title)
          .font(.largeTitle.bold())
          .padding(.horizontal)
          .contentTransition(.opacity)
          .animation(.default, value: title)
      }
  }
}

/// Lets a page's content run under the toolbar when it has a map header; otherwise the title goes in the navigation bar.
struct MapHeaderStyle: ViewModifier {
  let hasMap: Bool
  let title: String
  /// Leave the page alone when its container applies the style for all its pages.
  var isApplied = true

  func body(content: Content) -> some View {
    if !isApplied {
      content
    } else if hasMap {
      content
        .navigationTitle(title)  // Hidden below, but still titles the back button.
        .ignoresSafeArea(edges: .top)
        #if os(macOS)
          .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        #else
          .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        #endif
        #if !os(tvOS)
          .toolbar(removing: .title)
        #endif
        // A large title would show again, as the pushing page's title can set the mode for this one.
        #if os(iOS)
          .navigationBarTitleDisplayMode(.inline)
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
