//
//  VenuesMap.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/29/26.
//

import MapKit
import Shared
import SwiftUI
import os

extension Logger {
  fileprivate static let venuesMap = Logger(category: "venuesMap")
}

extension VaultModel {
  fileprivate func detail<V: Hashable & Identifiable & Nameable>(for item: V) -> Details
  where V.ID == ArchivePath {
    guard let mapItem = venueMapItemMap[item.id] else {
      return .init(coordinate: kCLLocationCoordinate2DInvalid, title: "Unknown")
    }
    return .init(coordinate: mapItem.location.coordinate, title: item.name)
  }
}

struct VenuesMap<V: Hashable & Identifiable & Nameable>: View where V.ID == ArchivePath {
  @Environment(VaultModel.self) private var model

  let items: any Collection<V>
  let searchString: String
  /// The map is released while it isn't shown.
  var isActive = true

  let navigateToPath: (ArchivePath) -> Void

  @State private var shownID = UUID()
  @State private var openedDetail = false

  @ViewBuilder private func clusterMap(_ memory: MapMemory) -> some View {
    ClusterMap(
      items: items, anchorY: CategoryAnnotationView.tipOffset, resetID: shownID,
      isSearching: !searchString.isEmpty, memory: memory
    ) {
      model.detail(for: $0)
    } onSelect: { item in
      Logger.venuesMap.info("select \(String(describing: item.id))")
      openedDetail = true
      withAnimation { navigateToPath(item.id) }
    } clusterLabel: {
      String(localized: "Cluster, \($0) venues")
    } itemContent: { item in
      CategoryAnnotationView(category: .venues, render: .default)
    } itemTitle: { item in
      CategoryTitleView(title: item.name)
    } clusterContent: {
      CategoryAnnotationView(category: .venues, render: .badge($0))
    }
  }

  var body: some View {
    OnScreenMap(isActive: isActive) { clusterMap($0) }
      .ignoresSafeArea()
      .onAppear {
        // Coming back from a venue's detail keeps the map as it was left.
        if openedDetail {
          openedDetail = false
        } else {
          shownID = UUID()
        }
      }
      .onChange(of: searchString) {
        // A search shows its results, wherever the map was moved to.
        shownID = UUID()
      }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model

  VenuesMap(items: model.previewAllVenues, searchString: "") { _ in }
}
