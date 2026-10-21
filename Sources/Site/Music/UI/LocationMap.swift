//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import MapKit
import Shared
import SwiftUI

private struct Place: Identifiable {
  let coordinate: CLLocationCoordinate2D

  var id: String { "\(coordinate.latitude),\(coordinate.longitude)" }
}

struct LocationMap: View {
  let geocodingInProgress: Bool
  @Binding var item: MKMapItem?
  var minHeight: CGFloat = 300

  var body: some View {
    ZStack {
      if let item {
        let place = Place(coordinate: item.location.coordinate)
        ClusterMap(
          items: [place], anchorY: CategoryAnnotationView.tipOffset, animatesFit: false,
          isSubdued: true
        ) {
          Details(coordinate: $0.coordinate, title: "")
        } onSelect: { _ in
        } clusterLabel: {
          String(localized: "Cluster, \($0) venues")
        } itemContent: { _ in
          CategoryAnnotationView(category: .venues, render: .default)
        } itemTitle: { _ in
          EmptyView()
        } clusterContent: {
          CategoryAnnotationView(category: .venues, render: .badge($0))
        }
        .allowsHitTesting(false)
        .overlay {
          Color.clear
            .contentShape(.rect)
            .onTapGesture {
              #if !os(tvOS)
                item.openInMaps()
              #endif
            }
        }
      } else if geocodingInProgress {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
      } else {
        ContentUnavailableView(
          String(localized: "Map Location Unavailable"),
          systemImage: "mappin.slash.circle",
          description: Text("Unable to determine map location."))
      }
    }
    .frame(minHeight: minHeight)
  }
}

#Preview("Progress View") {
  LocationMap(geocodingInProgress: true, item: .constant(nil))
}

#Preview("Unavailable View") {
  LocationMap(geocodingInProgress: false, item: .constant(nil))
}

#Preview("Current Location") {
  @Previewable @State var item = MKMapItem.forCurrentLocation()
  LocationMap(geocodingInProgress: false, item: .constant(item))
}
