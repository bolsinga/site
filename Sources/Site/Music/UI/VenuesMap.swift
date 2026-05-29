//
//  VenuesMap.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/29/26.
//

import MapKit
import SwiftUI
import os
import Shared

extension Logger {
  fileprivate static let venuesMap = Logger(category: "venuesMap")
}

extension VaultModel {
  fileprivate func mapItems<V: Hashable & Identifiable & Nameable & PathRestorable>(
    for items: any Collection<V>
  ) -> [V: MKMapItem] {
    items.reduce(into: [:]) { $0[$1] = venueMapItemMap[$1.archivePath] }
  }

  fileprivate func detail<V: Hashable & Identifiable & Nameable & PathRestorable>(for item: V)
    -> Details
  {
    guard let mapItem = venueMapItemMap[item.archivePath] else {
      return .init(coordinate: kCLLocationCoordinate2DInvalid, title: "Unknown")
    }
    return .init(coordinate: mapItem.location.coordinate, title: item.name)
  }
}

struct VenuesMap<V: Hashable & Identifiable & Nameable & PathRestorable>: View {
  @Environment(VaultModel.self) private var model

  private let debugShowItemsBounds = true
  private let useClusterMap = true

  let items: any Collection<V>
  @Binding var searchString: String
  @State private var cameraPosition: MapCameraPosition = .automatic

  let navigateToPath: (ArchivePath) -> Void

  private var cMapItemsMap: [V: MKMapItem] {
    model.mapItems(for: items)
  }

  private func changing() {
    let mapItemsMap = cMapItemsMap
    self.cameraPosition = .rect(mapItemsMap.values.rect.proportionallyPadded)

    Logger.venuesMap.info("changing: Items: \(items.count) mapItems: \(mapItemsMap.count)")
  }

  @ViewBuilder private var map: some View {
    let items = Array(cMapItemsMap.values)
    Map(
      initialPosition: cameraPosition,
      interactionModes: MapInteractionModes()
    ) {
      ForEach(items, id: \.self) { item in
        Marker(item: item)
      }

      if debugShowItemsBounds {
        let itemsRect = items.rect
        let rect = itemsRect.proportionallyPadded
        MapPolygon(points: rect.corners)
          .foregroundStyle(.purple.opacity(0.5))

        MapPolygon(points: itemsRect.corners)
          .foregroundStyle(.red.opacity(0.5))
      }
    }
  }

  @ViewBuilder private var clusterMap: some View {
    ClusterMap(items: items, anchorY: CategoryAnnotationView.tipOffset) {
      model.detail(for: $0)
    } onSelect: { item in
      Logger.venuesMap.info("select \(String(describing: item.archivePath))")
      withAnimation { navigateToPath(item.archivePath) }
    } itemContent: { item in
      CategoryAnnotationView(category: .venues, render: .default, title: item.name)
    } clusterContent: {
      CategoryAnnotationView(category: .venues, render: .badge($0))
    }
  }

  @ViewBuilder private var mapView: some View {
    if useClusterMap {
      clusterMap
    } else {
      map
    }
  }

  var body: some View {
    mapView
      .navigationTitle(ArchiveCategory.venues.localizedString)
      #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
      .archiveSearchable(
        searchPrompt: String(localized: "Venue Names"),
        searchString: $searchString,
        contentsEmpty: items.isEmpty
      )
      .onChange(of: model.venueMapItemMap) { _, _ in
        changing()
      }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  @Previewable @State var searchString = ""

  VenuesMap(items: model.previewAllVenues, searchString: $searchString) { _ in }
}
