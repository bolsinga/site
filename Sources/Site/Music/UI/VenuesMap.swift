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

  let items: any Collection<V>

  let navigateToPath: (ArchivePath) -> Void

  @State private var shownID = UUID()
  @State private var openedDetail = false

  @ViewBuilder private var clusterMap: some View {
    ClusterMap(items: items, anchorY: CategoryAnnotationView.tipOffset, resetID: shownID) {
      model.detail(for: $0)
    } onSelect: { item in
      Logger.venuesMap.info("select \(String(describing: item.archivePath))")
      openedDetail = true
      withAnimation { navigateToPath(item.archivePath) }
    } itemContent: { item in
      CategoryAnnotationView(category: .venues, render: .default, title: item.name)
    } clusterContent: {
      CategoryAnnotationView(category: .venues, render: .badge($0))
    }
  }

  var body: some View {
    clusterMap
      .onAppear {
        // Coming back from a venue's detail keeps the map as it was left.
        if openedDetail {
          openedDetail = false
        } else {
          shownID = UUID()
        }
      }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model

  VenuesMap(items: model.previewAllVenues) { _ in }
}
